require_relative '../spec_helper'

describe 'API Authentication' do
  before do
    @fake_token = 'some_fb_token'
    @time = Time.now
    allow(Net::HTTP).to receive(:get).and_return(JSON.dump({'id' => '12345'}))
    allow(Time).to receive(:now).and_return(@time)
  end

  describe 'when the request is successful' do
    before :each do
      post '/api/auth/12345', :token => @fake_token
      @token = last_response.headers['Authorization']
    end

    it 'has a response status of 200 when successful' do
      expect(last_response).to be_ok
    end

    it 'returns something in the Authorization header' do
      expect(@token).not_to be_nil
    end

    it 'returns a token that can be decoded using JWT and has expires and fbid fields' do
      time = (@time + app().settings.token_expire_days * 24*60*60).to_i
      decoded_token = JWT.decode(@token, app().settings.token_secret)
      expect(decoded_token[0]['expires']).to eq time
      expect(decoded_token[0]['fbid']).to eq '12345'
    end
  end

  it "returns an error if the id in the url doesn't match" do
    post '/api/auth/99999', :token => @fake_token
    error_msg = "The provided token doesn't belong to the user"
    expect(last_response.status).to eq 401
    expect(JSON.parse(last_response.body)['message']).to eq error_msg
  end

  it "returns the Facebook API error if Facebook API returns one" do
    fb_error = {:error => {:message => 'some error'}}
    allow(Net::HTTP).to receive(:get).and_return(JSON.dump(fb_error))
    post '/api/auth/12345', :token => @fake_token
    expect(last_response.status).to eq 401
    expect(JSON.parse(last_response.body)['message']).to eq fb_error[:error][:message]
  end
end

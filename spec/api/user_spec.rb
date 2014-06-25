require_relative '../spec_helper'

describe 'Users' do
  describe :GET do
    describe 'when the requested user exists' do
      before do
        get '/api/user/1', {}, @request_headers
      end

      it 'responds with status 200' do
        expect(last_response).to be_ok
      end

      it 'returns the created user in JSON format' do
        result = JSON.parse(last_response.body)
        expect(result['fbid']).to eq '1'
      end
    end

    it "fails when the user doesn't exist" do
        get '/api/user/2', {}, @request_headers
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'User not found'
    end
  end

  describe :POST do
    describe 'when the request is successful' do
      before :each do
        token = generate_token(2)
        post '/api/user', {}, {'HTTP_AUTHORIZATION' => token}
      end

      it 'responds with status 200' do
        expect(last_response).to be_ok
      end

      it 'creates a user with a General group' do
        result = JSON.parse(last_response.body)
        expect(User.find(result['_id'])).not_to be_nil
        expect(User.find(result['_id']).fbid).to eq '2'
        expect(User.find(result['_id']).groups[0].name).to eq 'General'
      end
    end

    it 'fails when the request user already exists' do
      dbl = double(User, :fbid => '1')
      allow(User).to receive(:where).and_return(dbl)
      allow(dbl).to receive(:first).and_return(dbl)
      post '/api/user', {}, @request_headers
      expect(last_response.status).to eq 400
      expect(JSON.parse(last_response.body)['message']).to eq 'User already exists'
    end
  end
end

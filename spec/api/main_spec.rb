describe 'Main' do
  describe 'All routes' do
    it "fail if the given token has expired" do
      get '/api/all_routes', {}, {'HTTP_AUTHORIZATION' => generate_token(2, 0)}
      expect(last_response.status).to eq 401
      expect(JSON.parse(last_response.body)['message']).to match /expired/
    end

    it "fail if the given token is not valid" do
      post '/api/all_routes', {}, {'HTTP_AUTHORIZATION' => 'wrong token'}
      expect(last_response.status).to eq 401
      expect(JSON.parse(last_response.body)['message']).to eq 'Invalid token'
    end
  end

  describe 'Main route' do
    it 'returns the api version' do
      get '/api'
      expect(JSON.parse(last_response.body)['version']).to eq app()::API_VERSION
    end
  end

  describe 'All group routes' do
    it 'check if the given group exists' do
      get '/api/groups/666', {}, @request_headers
      expect(last_response.status).to eq 404
      expect(JSON.parse(last_response.body)['message']).to eq 'Unknown group'
    end
  end
end

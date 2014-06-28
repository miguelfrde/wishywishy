describe 'Groups' do
  before do
    @general_group = @user.groups.where(name: 'General').first
    @group1 = Group.new(name: 'Group one')
    @group1.wishes << Item.new(name: 'Test item')
    @item = @group1.wishes[0]
    @user.groups << @group1
  end

  describe 'GET ALL' do
    before do
      get '/api/groups', {}, @request_headers
    end

    it 'has a successful status' do
      expect(last_response).to be_ok
    end

    it 'returns all user groups for the current user' do
      result = JSON.parse(last_response.body)
      general = {'name' => @general_group.name, '_id' => @general_group.id}
      group1 = {'name' => @group1.name, '_id' => @group1.id}
      expect(result.size).to eq 2
      expect(result[0]).to include general
      expect(result[1]).to include group1
    end
  end

  describe :GET do
    before do
      get "/api/groups/#{@group1.id}", {}, @request_headers
    end

    it 'has a successful status' do
      expect(last_response).to be_ok
    end

    it 'returns all user groups for the current user' do
      result = JSON.parse(last_response.body)
      expect(result).to include({'name' => @group1.name, '_id' => @group1.id})
    end
  end

  describe :POST do
    context 'when no name is received' do
      before do
        post '/api/groups', {}, @request_headers
      end

      it 'responds with an error' do
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'No name provided'
      end
    end

    context "when there exists a group of the same name" do
      before do
        post '/api/groups', {:name => 'General'}, @request_headers
      end

      it 'responds with an error' do
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 403
        expect(JSON.parse(last_response.body)['message']).to eq 'Group already exists'
      end
    end

    context 'when successful' do
      before do
        post '/api/groups', {:name => 'Test'}, @request_headers
      end

      it 'has a successful status' do
        expect(last_response).to be_ok
      end

      it 'creates a new group' do
        expect(Group.where(name: 'Test').first).not_to be_nil
      end

      it 'creates a new group with the given name for the given user' do
        @user.reload
        expect(@user.groups.where(name: 'Test')).not_to be_nil
      end

      it 'responds with the group as JSON data' do
        result = JSON.parse(last_response.body)
        expect(result).to include({'name' => 'Test'})
      end
    end
  end

  describe :PUT do
    context 'when no name is received' do
      before do
        put "/api/groups/#{@group1.id}", {}, @request_headers
      end

      it 'responds with an error' do
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'No name provided'
      end
    end

    context "when there exists a group of the same name" do
      before do
        put "/api/groups/#{@group1.id}", {:name => 'General'}, @request_headers
      end

      it 'responds with an error' do
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 403
        expect(JSON.parse(last_response.body)['message']).to eq 'Group already exists'
      end
    end

    context "when an update on the Genral group is requested" do
      before do
        put "/api/groups/#{@general_group.id}", {:name => 'F'}, @request_headers
      end

      it 'responds with an error' do
        error_msg = "General group cannot be updated"
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 403
        expect(JSON.parse(last_response.body)['message']).to eq error_msg
      end
    end

    context 'when successful' do
      before do
        put  "/api/groups/#{@group1.id}", {:name => 'Test'}, @request_headers
      end

      it 'has a successful status' do
        expect(last_response).to be_ok
      end

      it "updates the group's name" do
        @user.reload
        expect(@user.groups.where(name: 'Test').first).not_to be_nil
        expect(@user.groups.where(name: 'Group one').first).to be_nil
      end
    end
  end

  describe :DELETE do
    context "when an update on the Genral group is requested" do
      before do
        delete "/api/groups/#{@general_group.id}", {}, @request_headers
      end

      it 'responds with an error' do
        error_msg = "General group cannot be deleted"
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 403
        expect(JSON.parse(last_response.body)['message']).to eq error_msg
      end
    end

    context 'when successful' do
      before do
        delete  "/api/groups/#{@group1.id}", {}, @request_headers
        @user.reload
      end

      it 'has a successful status' do
        expect(last_response).to be_ok
      end

      it "deletes the group" do
        @user.reload
        expect(@user.groups.where(name: 'Group one').first).to be_nil
      end

      it "deletes the items (wishes) associated to the group" do
        expect{ Item.find(@item1) }.to raise_error
      end
    end
  end
end

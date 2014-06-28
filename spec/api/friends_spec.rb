require_relative '../spec_helper'

describe 'Friends' do
  before do
    @general_group = @user.groups.where(name: 'General').first
    @friend = FactoryGirl.build(:user)
    @general_group.friends << @friend
  end

  describe :GET do
    before do
      get "/api/groups/#{@general_group.id}/friends", {}, @request_headers
    end

    it 'succeeds everytime when group exists' do
      expect(last_response).to be_ok
    end

    it 'returns all friends that belong to the given group' do
      expect(JSON.parse(last_response.body)[0]['fbid']).to eq @friend.fbid
    end
  end

  describe :POST do
    describe 'when it succeeds' do
      before do
        post "/api/groups/#{@general_group.id}/friends/#{@friend.fbid}", {},
          @request_headers
      end

      it 'has a successful status code' do
        expect(last_response).to be_ok
      end

      it 'adds a new friend to the given group' do
        expect(@general_group.friends).to include @friend
      end
    end

    it "fails when the given user doens't exist" do
      post "/api/groups/#{@general_group.id}/friends/666", {}, @request_headers
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq 404
      expect(JSON.parse(last_response.body)['message']).to eq 'Unknown user'
    end
  end

  describe :DELETE do
    describe 'when the user exists' do
      before :each do
        delete "/api/groups/#{@general_group.id}/friends/#{@friend.fbid}", {},
          @request_headers
      end

      it 'has a successful status code when the group exists' do
        expect(last_response).to be_ok
      end

      it "deletes a given user from the given group's friends list" do
        @general_group.reload
        expect(@general_group.friends).not_to include @friend
      end

      it "doesn't destroy the given user" do
        expect{ User.find(@friend.id) }.not_to raise_error
      end
    end

    it "fails when the user doesn't exist" do
      delete "/api/groups/#{@general_group.id}/friends/666", {},
        @request_headers
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq 404
      expect(JSON.parse(last_response.body)['message']).to eq 'Unknown user'
    end
  end
end

describe 'Gifts' do
  before do
    @gift = Item.new(name: 'Gift', picked: true)
    @friend = User.create(fbid: '2', events: [])
    @friend.groups << Group.create(name: 'General')
    @friend.groups.where(name: 'General').first.wishes << @gift
    @user.groups.where(name: 'General').first.friends << @friend
    @user.gifts << @gift
  end

  describe 'GET ALL' do
    before do
      get '/api/gifts', {}, @request_headers
    end

    it 'has a successful response' do
      expect(last_response).to be_ok
    end

    it 'returns all gifts associated to the user' do
      result = JSON.parse(last_response.body)
      expect(result.size).to eq 1
      expect(result[0]['_id']).to eq "#{@gift.id}"
    end
  end

  describe :GET do

    context "when the gift is not found in the user's gifts" do
      it 'responds with an error' do
        get '/api/gifts/666', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown gift'
      end
    end

    context 'when the request is successful' do
      before do
        get "/api/gifts/#{@gift.id}", {}, @request_headers
      end

      it 'has a successful response' do
        expect(last_response).to be_ok
      end

      it 'returns the requested gift' do
        result = JSON.parse(last_response.body)
        expect(result['_id']).to eq @gift.id.to_s
        expect(result['name']).to eq @gift.name
        expect(result['picker_id']).to eq @user.id.to_s
        expect(result['picked']).to eq true
      end
    end
  end

  describe :POST do
    context "when it responds with an error" do
      it "doesn't receive a gift ID" do
        post '/api/gifts', {}, @request_headers
        error_msg = 'Provide an item (gift/wish) ID'
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq error_msg
      end

      it "receives an unknwon gift ID" do
        post '/api/gifts', {:gift => '666'}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown gift'
      end

      it "receives a gift that is currently picked" do
        post '/api/gifts', {:gift => @gift.id}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'Gift already picked'
      end
    end

    context 'when it succeeds' do
      before do
        @new_gift = Item.create(name: 'New gift')
        post '/api/gifts', {:gift => @new_gift.id}, @request_headers
        @new_gift.reload
        @user.reload
      end

      it 'return s a successful status' do
        expect(last_response).to be_ok
      end

      it 'sets the current user as the gift picker' do
        expect(@user.gifts).to include @new_gift
        expect(@new_gift.picker).to eq @user
      end

      it 'sets the given gift as picked' do
        expect(@new_gift.picked).to be_truthy
      end
    end
  end

  describe :DELETE do
    context "when it responds with an error" do
      it "receives an unknwon gift ID" do
        delete '/api/gifts/666', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown gift'
      end

      it "receives a gift that doesn't belong to the current user" do
        allow(Item).to receive(:find).and_return Item.create(name: 'X')
        delete '/api/gifts/666', {}, @request_headers
        error_msg = "Gift doesn't belong to current user"
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq error_msg
      end
    end
  end

  context "when it succeeds" do
    before do
      delete "/api/gifts/#{@gift.id}", {}, @request_headers
      @user.reload
      @gift.reload
    end

    it 'return s a successful status' do
      expect(last_response).to be_ok
    end

    it "removes the gift from the current user's gifts" do
      expect(@gift.picker).to be_nil
      expect(@user.gifts).not_to include @gift
    end

    it "sets the gift as unkpicked" do
      expect(@gift.picked).to be_falsey
    end
  end
end

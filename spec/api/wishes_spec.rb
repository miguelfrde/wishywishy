describe 'Wishes' do
  before do
    @wish1 = Item.create(name: 'Wish one')
    @wish2 = Item.create(name: 'Wish two')
    @group = @user.groups.where(name: 'General').first
    @group.wishes << @wish1
    @group.wishes << @wish2
  end

  describe 'GET ALL' do
    it 'returns all wishes associated to a group' do
      get "/api/groups/#{@group.id}/wishes", {}, @request_headers
      expect(last_response).to be_ok
      result = JSON.parse(last_response.body)
      expect(result.size).to eq 2
      result_ids = result.map{ |w| w['_id'] }
      expect(result_ids).to include "#{@wish1.id}"
      expect(result_ids).to include "#{@wish2.id}"
    end
  end

  describe :GET do
    context "when the wish doesn't exist" do
      it "fails" do
        get '/api/wishes/666', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown wish'
      end
    end

    context 'when the wish exists' do
      before do
        get "/api/wishes/#{@wish1.id}", {}, @request_headers
      end

      it 'has a successful status' do
        expect(last_response).to be_ok
      end

      it 'receives the wish as JSON' do
        result = JSON.parse(last_response.body)
        expect(result['_id']).to eq "#{@wish1.id}"
        expect(result['name']).to eq "#{@wish1.name}"
      end
    end
  end

  describe :POST do
    context "when it fails" do
      it "doesn't receive a name" do
        post '/api/wishes', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'Provide a name'
      end

      it "doesn't receive a group" do
        post '/api/wishes', {:name => 'New wish'}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'Provide a group'
      end

      it "receives a group that doesn't exist" do
        post '/api/wishes', {:name => 'New wish', :group => 666}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown group'
      end
    end

    context 'when successful' do
      before do
        request_params = {:name => 'New wish', :group => @group.id, :event => 'Event'}
        post '/api/wishes', request_params, @request_headers
        @group.reload
      end

      it 'adds the wish to the list of wishes in given group' do
        id = JSON.parse(last_response.body)['_id']
        expect(@group.wishes.find(id)).not_to be_nil
      end

      it 'adds a wish with the given name' do
        id = JSON.parse(last_response.body)['_id']
        expect(@group.wishes.find(id).name).to eq 'New wish'
      end

      it 'adds a wish with the given event' do
        id = JSON.parse(last_response.body)['_id']
        expect(@group.wishes.find(id).event).to eq 'Event'
      end

      it "adds the event to the list of user events if it doens't exist" do
        @user.reload
        expect(@user.events.where(name: 'Event').first).not_to be_nil
      end
    end
  end

  describe :PUT do
    context "when the wish doesn't exist" do
      it "fails" do
        put '/api/wishes/666', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown wish'
      end
    end

    context 'when successful' do
      before do
        put "/api/wishes/#{@wish1.id}", {:event => 'Update'}, @request_headers
        @wish1.reload
      end

      it 'has a successful status' do
        expect(last_response).to be_ok
      end

      it "updates the wish's event" do
        expect(last_response).to be_ok
        expect(@wish1.event).to eq 'Update'
      end
    end

  end

  describe :DELETE do
    context "when the wish doesn't exist" do
      it "fails" do
        delete '/api/wishes/666', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 404
        expect(JSON.parse(last_response.body)['message']).to eq 'Unknown wish'
      end
    end

    context "when the wish exists" do
      it 'deletes the wish' do
        delete "/api/wishes/#{@wish1.id}", {}, @request_headers
        expect{ @user.wishes.find(@wish1.id) }.to raise_error
      end
    end
  end
end

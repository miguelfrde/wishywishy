require_relative '../spec_helper'

describe 'Events' do
  shared_examples_for 'event existance' do
    it "fails if the given id isn't associated to any event" do
      get '/api/event/666', {}, @request_headers
      expect(last_response).not_to be_ok
      expect(last_response.status).to eq 404
      expect(JSON.parse(last_response.body)['message']).to eq 'Unkown event'
    end
  end

  before do
    @event1 = Event.new(name: 'Event one')
    @event2 = Event.new(name: 'Event two')
    @user.events << @event1
    @user.events << @event2
  end

  describe :GET_ALL do
    before do
      get '/api/events', {}, @request_headers
    end

    it 'is always successful if the auth token passes main validations' do
      expect(last_response).to be_ok
    end

    it 'returns all the user events' do
      result = JSON.parse(last_response.body)
      expect(result.size).to eq 2
      expect(result).to include @event1.as_document
      expect(result).to include @event2.as_document
    end
  end

  describe :GET_ONE do
    it_checks_for 'event existance'

    context 'when the event exists' do
      before do
        get "/api/event/#{@event1.id}", {}, @request_headers
      end

      it 'is successful' do
        expect(last_response).to be_ok
      end

      it 'returns the event' do
        result = JSON.parse(last_response.body)
        expected_event = Hash[@event1.as_document.map{ |k, v| [k, v.to_s] }]
        expect(result).to eq expected_event
      end
    end
  end

  describe :POST do
    context 'when the params are not provided as expected' do
      it 'fails when the name is not provided' do
        post '/api/event', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'No name provided'
      end

      it "fails when there's an event with the same name" do
        post '/api/event', {:name => 'Event one'}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'Event already exists'
      end
    end

    context 'when the params are provided as expected' do
      before do
        post '/api/event', {:name => 'New Event'}, @request_headers
        @user.reload
      end

      it 'should response with a successful status' do
        expect(last_response).to be_ok
      end

      it 'should create a new event with the given name' do
        expect(@user.events.where(name: 'New Event').first).not_to be_nil
      end

      it 'should return the new event' do
        result = JSON.parse(last_response.body)
        id = @user.events.where(name: 'New Event').first.id
        expect(result.keys.size).to eq(2)
        expect(result).to include '_id' => id
        expect(result).to include 'name' => 'New Event'
      end
    end
  end

  describe :PUT do
    it_checks_for 'event existance'

    context 'when the params are not provided as expected' do
      it 'fails when the name is not provided' do
        post '/api/event', {}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'No name provided'
      end

      it "fails when there's an event with the same name" do
        post '/api/event', {:name => 'Event one'}, @request_headers
        expect(last_response).not_to be_ok
        expect(last_response.status).to eq 400
        expect(JSON.parse(last_response.body)['message']).to eq 'Event already exists'
      end
    end

    context 'when the params are provided as expected' do
      before do
        put "/api/event/#{@event1.id}", {:name => 'Edited event'}, @request_headers
        @event1.reload
      end

      it 'should respond with a successful status' do
        expect(last_response).to be_ok
      end

      it "updates the given event's name" do
        expect(@event1.name).to eq 'Edited event'
      end
    end
  end

  describe :DELETE do
    it_checks_for 'event existance'

    before do
      delete "/api/event/#{@event1.id}"
    end

    it 'deletes the given event' do
      expect{ Event.find(@event1.id) }.to raise_error
    end
  end
end

class WishyWishyApp < Sinatra::Base
  def event_by_id
    event = @current_user.events.find(params[:event]) rescue nil
    halt json_status 404, 'Unkown event' if event.nil?
    event
  end

  get '/api/events' do
    json @current_user.events
  end

  get '/api/event/:event' do
    event = event_by_id(params[:event])
    json event
  end

  post '/api/event' do
    halt json_status 400, 'No name provided' if params[:name].nil?
    new_event = Event.create(name: params[:name])
    @current_user.events << new_event
    json new_event.only(:_id, :name)
  end

  put '/api/event/:event' do
    halt json_status 400, 'No name prvided' if params[:name].nil?
    event = event_by_id(params[:event])
    event.update_attributes(name: params[:name])
  end

  delete '/api/event/:event' do
    halt json_status 400, 'No name prvided' if params[:name].nil?
    event = event_by_id(params[:event])
    event.delete
  end
end

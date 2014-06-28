class WishyWishyApp < Sinatra::Base
  before %r{/api/wishes/([0-9a-f]+)} do
    @wish = Item.find(params[:captures].first) rescue nil
    halt json_status 404, 'Unknown wish' if @wish.nil?
  end

  get '/api/groups/:group/wishes' do
    json @group.wishes
  end

  get '/api/wishes/:wish' do
    json @wish
  end

  post '/api/wishes' do
    halt json_status 400, 'Provide a name' if params[:name].nil?
    halt json_status 400, 'Provide a group' if params[:group].nil?
    group = Group.find(params[:group]) rescue nil
    halt json_status 404, 'Unknown group' if group.nil?
    wish = Item.create(name: params[:name])
    unless params[:event].nil?
      event = @current_user.events.find_or_create_by(name: params[:event])
      wish.event = event.name
    end
    group.wishes << wish
    # TODO: support pictures
    json wish
  end

  put '/api/wishes/:wish' do
    @wish.update_attributes(event: params[:event] ) unless params[:event].nil?
    # TODO: support pictures
    json :success => true
  end

  delete '/api/wishes/:wish' do
    @wish.delete
    json :success => true
  end
end

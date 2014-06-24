class WishyWishyApp < Sinatra::Base
  before %r{/api/wishes/(\d+)} do
    @wish = Item.find(params[:captures].first)
    halt json_status 404, 'Unknown wish' if @wish.nil?
  end

  get '/api/wishes/:wish' do
    json @wish
  end

  get '/api/groups/:group/wishes' do
    json @group.wishes
  end

  post '/api/wishes' do
    halt json_status 400, 'Please provide a name' if params[:name].nil?
    halt json_status 400, 'Please provide a group' if params[:group].nil?
    group = Group.find(params[:group])
    halt json_status 404, 'Unknown group' if group.nil?
    wish = Item.create(
      name: params[:name],
      picked: false
    )
    wish.event = params[:event] unless params[:event].nil?
    group.wishes << wish
    # TODO: support pictures
    json wish.only(:_id, :name)
  end

  put '/api/wishes/:wish' do
    @wish.event = params[:event] unless params[:event].nil?
    # TODO: support pictures
    json :success => true
  end

  delete '/api/wishes/:wish' do
    @wish.delete
    json :success => true
  end
end

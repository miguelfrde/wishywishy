class WishyWishyApp < Sinatra::Base
  get '/api/groups' do
    json @current_user.groups.only(:_id, :name)
  end

  get '/api/groups/:group' do
    json @group
  end

  post '/api/groups' do
    halt json_status 400, 'No name provided' if params[:name].nil?
    halt json_status 403, 'Group already exists' unless
      @current_user.groups.where(name: params[:name]).first.nil?
    new_group = Group.create(name: params[:name])
    @current_user.groups << new_group
    json new_group
  end

  put '/api/groups/:group' do
    halt json_status 403, "General group cannot be updated" if
      @group.name == 'General'
    halt json_status 400, 'No name provided' if params[:name].nil?
    halt json_status 403, 'Group already exists' unless
      @current_user.groups.where(name: params[:name]).first.nil?
    @group.update_attributes(name: params[:name])
  end

  delete '/api/groups/:group' do
    halt json_status 403, 'General group cannot be deleted' if
      @group.name == 'General'
    @group.wishes.delete_all
    @group.delete
    json :success => true
  end
end

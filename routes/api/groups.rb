class WishyWishyApp < Sinatra::Base
  get '/api/groups' do
    json @current_user.groups.only(:_id, :name)
  end

  get '/api/groups/:group' do
    json @group
  end

  post '/api/groups' do
    halt 400, 'Please provide a name' if params[:name].nil?
    new_group = Group.create(name: params[:name])
    @current_user.groups << new_group
    json new_group.only(:_id, :name)
  end

  put '/api/groups/:group' do
    group = @current_user.groups.find(params[:group])
    halt json_status 400, 'Unknown group' if group.nil?
  end

  delete '/api/groups/:group' do
    general_group = Group.where(:owner => @current_user, :name => 'General')
    halt json_status 403, 'General group cannot be deleted' if
      @group == general_group
    @group.items.destroy_all
    @group.delete
  end
end

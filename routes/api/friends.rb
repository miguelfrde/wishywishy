class WishyWishyApp < Sinatra::Base
  get '/api/groups/:group/friends' do
    json @group.friends.only(:fbid)
  end

  post '/api/groups/:group/friends/:friend_fbid' do
    new_friend = User.where(fbid: params[:friend_fbid]).first
    halt json_status, 404, 'Unknown user'
    @group.friends << new_friend
    json :success => true
  end

  delete '/api/groups/:group/friends/:friend_fbid' do
    @current_user.friends.delete_all(fbid: params[:friend_fbid])
  end
end

class WishyWishyApp < Sinatra::Base
  get '/api/groups/:group/friends' do
    json @group.friends.only(:fbid)
  end

  post '/api/groups/:group/friends/:friend_fbid' do
    new_friend = User.where(fbid: params[:friend_fbid]).first
    halt json_status 404, 'Unknown user' if new_friend.nil?
    @group.friends << new_friend
    json :success => true
  end

  delete '/api/groups/:group/friends/:friend_fbid' do
    friend = User.where(fbid: params[:friend_fbid]).first
    halt json_status 404, 'Unknown user' if friend.nil?
    @group.friends.delete(friend)
    json :success => true
  end
end

class WishyWishyApp < Sinatra::Base
  get '/api/user/:fbid' do
    user = User.where(fbid: params[:fbid]).first
    halt json_status 404, 'User not found' if user.nil?
    # TODO: check that user is friend of @current_user
    json user
  end

  post '/api/user' do
    halt json_status 400, 'User already exists' unless @current_user.nil?
    new_user = User.create(events: [], fbid: @id)
    new_user.groups << Group.create(name: 'General')
    json new_user
  end
end

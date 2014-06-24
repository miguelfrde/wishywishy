class WishyWishyApp < Sinatra::Base
  get '/api/gifts' do
    json @current_user.gifts
  end

  get '/api/gifts/:gift' do
    gift = @current_user.gifts.find(params[:gift])
    halt 404, 'Gift not found' if gift.nil?
    json gift
  end

  post '/api/gifts/' do
    halt 400, 'Provide an item (gift/wish) ID' if params[:gift].nil?
    item = Item.find(params[:gift])
    halt 404, 'Unknown gift' if item.nil?
    halt 400, 'Gift currently picked' if item.picked
    @current_user.gifts << item
    item.picked = true
    json :success => true
  end

  delete '/api/gifts/:gift' do
    item = Item.find(params[:gift])
    halt 404, 'Unknown gift' if item.nil?
    halt 404, "Gift doesn't belong to current user" if
      @current_user.gifts.find(params[:gift]).nil?
    @current_user.delete(item)
    item.picked = false
    json :success => true
  end
end

class WishyWishyApp < Sinatra::Base
  get '/api/gifts' do
    json @current_user.gifts
  end

  get '/api/gifts/:gift' do
    gift = @current_user.gifts.find(params[:gift]) rescue nil
    halt json_status 404, 'Unknown gift' if gift.nil?
    json gift
  end

  post '/api/gifts' do
    halt json_status 400, 'Provide an item (gift/wish) ID' if params[:gift].nil?
    item = Item.find(params[:gift]) rescue nil
    halt json_status 404, 'Unknown gift' if item.nil?
    halt json_status 400, 'Gift already picked' if item.picked
    item.picked = true
    @current_user.gifts << item
    json :success => true
  end

  delete '/api/gifts/:gift' do
    item = Item.find(params[:gift]) rescue nil
    halt json_status 404, 'Unknown gift' if item.nil?
    check_user_gifts = @current_user.gifts.find(item) rescue nil
    halt json_status 400, "Gift doesn't belong to current user" if
      check_user_gifts.nil?
    item.picked = false
    item.save
    @current_user.gifts.delete(item)
    json :success => true
  end
end

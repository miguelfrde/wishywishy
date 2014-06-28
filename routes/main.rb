class WishyWishyApp < Sinatra::Base
  get '/' do
    send_file 'views/comingsoon.html'
  end
end

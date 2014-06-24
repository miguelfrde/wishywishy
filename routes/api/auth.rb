require 'net/http'
require 'json'

class WishyWishyApp < Sinatra::Base
  post '/api/auth/:id' do
    tokenfb = params[:token]
    url = URI.parse("https://graph.facebook.com/me?access_token=#{tokenfb}")
    res = JSON.parse(Net::HTTP.get(url))

    halt json_status 401, res['error']['message'] if res['error']
    halt json_status 401, "The provided token doesn't belong to the user" unless
      res['id'] == params[:id]

    token = {
      :expires => (Time.now + settings.token_expire_days * 24*60*60).to_i,
      :fbid => params[:id]
    }
    token = JWT.encode(token, settings.token_secret)
    response.headers['Authorization'] = token

    json :success => true
  end
end

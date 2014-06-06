require 'net/http'
require 'json'

class WishyWishyApp < Sinatra::Base
  before %r{^/api/(\w+)} do
    pass if params[:captures].first =~ /^auth/

    token = request.env['HTTP_AUTHORIZATION']
    token = JWT.decode(token, settings.token_secret) rescue nil
    token = token[0] unless token.nil?

    halt json_status 401, 'Invalid token' if token.nil?
    halt json_status 401, 'Token has expired' if
      Time.now > Time.at(token['expires'])

    @id = token['fbid']
  end

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

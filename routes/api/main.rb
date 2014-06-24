class WishyWishyApp < Sinatra::Base
  before %r{/api(.*)} do
    content_type :json
    pass if params[:captures].first == ''
    halt json_status 400, 'Please use SSL' if
      settings.force_ssl && !request.secure?
  end

  before %r{^/api/(\w+)} do
    pass if params[:captures].first =~ /^auth/

    token = request.env['HTTP_AUTHORIZATION']
    token = JWT.decode(token, settings.token_secret) rescue nil
    token = token[0] unless token.nil?

    halt json_status 401, 'Invalid token' if token.nil?
    halt json_status 401, 'Token has expired' if
      Time.now > Time.at(token['expires'])

    @id = token['fbid']
    @current_user = User.where(fbid: @id).first
  end

  before %r{/api/groups/(\d+)/?(.*)} do
    @group = @current_user.groups.find(params[:captures].first)
    halt json_status 404, 'Unknown group' if @group.nil?
  end

  get %r{/api/?} do
    json :version => API_VERSION
  end
end

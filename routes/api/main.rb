class WishyWishyApp < Sinatra::Base
  before %r{/api(.*)} do
    content_type :json
    pass if params[:captures].first == ''
    if settings.force_ssl && !request.secure?
      halt json_status 400, 'Please use SSL'
    end
  end

  get %r{/api/?} do
    json :version => API_VERSION
  end
end

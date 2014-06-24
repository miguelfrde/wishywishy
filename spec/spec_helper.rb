require 'rack/test'

require_relative '../app.rb'

ENV['RACK_ENV'] = 'test'

module RSpecMixin
  include Rack::Test::Methods
  def app() WishyWishyApp end
end

RSpec.configure { |c| c.include RSpecMixin }

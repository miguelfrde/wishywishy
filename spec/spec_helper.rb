require 'rack/test'

require_relative '../app.rb'

Bundler.require :test

module RSpecMixin
  include Rack::Test::Methods
  def app() WishyWishyApp end
end

RSpec.configure do |config|
  config.include RSpecMixin
  config.include FactoryGirl::Syntax::Methods

  config.before :suite do
    if ENV['RACK_ENV'] == 'localtest' && `ps -eaf | grep mongo` !~ /mongod/
      $stderr.puts "\e[0;31mERROR: mongod is not running. Please start it!\e[0m"
      exit
    end
    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner[:mongoid].clean_with :truncation
  end

  config.before :each do
    DatabaseCleaner.start
    @user = User.create(events: [], fbid: '1')
    @user.groups << Group.new(name: 'General')
    token = generate_token(1)
    @request_headers = {'HTTP_AUTHORIZATION' => token}
  end

  config.after :each do
    DatabaseCleaner.clean
  end

  def generate_token(fbid, expires = 9999999999)
    JWT.encode({
        :expires => expires,
        :fbid => fbid.to_s
      }, app().settings.token_secret)
  end
end

FactoryGirl.find_definitions

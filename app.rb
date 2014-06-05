require 'rubygems'
require 'bundler'
require 'sinatra/base'
Bundler.require

require_relative 'routes/init'
require_relative 'helpers/init'
require_relative 'models/init'

class WishyWishyApp < Sinatra::Base
  enable :method_override
  enable :sessions
  set :session_secret, 'super secret'

  configure do
    set :app_file, __FILE__
    mongo_url = 'mongodb://localhost/wishywishy' || ENV['MONGOHQ_URL']
    MongoMapper.connection = Mongo::Connection.from_uri mongo_url
    MongoMapper.database = URI.parse(mongo_url).path.gsub(/^\//, '')
  end

  configure :development do
    enable :logging, :dump_errors, :raise_errors
  end

  configure :production do
    set :raise_errors, false
    set :show_exceptions, false
  end
end

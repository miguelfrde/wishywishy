require 'rubygems'
require 'bundler'
require 'sinatra/base'
Bundler.require

require_relative 'routes/init'
require_relative 'helpers/init'
require_relative 'models/init'

DataMapper.setup(:default,
  ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class WishyWishyApp < Sinatra::Base
  enable :method_override
  enable :sessions
  set :session_secret, 'super secret'

  configure do
    set :app_file, __FILE__
  end

  configure :development do
    enable :logging, :dump_errors, :raise_errors
  end

  configure :production do
    set :raise_errors, false
    set :show_exceptions, false
  end
end

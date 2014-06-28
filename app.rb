require 'rubygems'
require 'bundler'
require 'sinatra'
require 'sinatra/json'
Bundler.require

class WishyWishyApp < Sinatra::Base
  API_VERSION = '1.0'

  configure do
    # enable :sessions
    # set :session_secret, '*m!e-ypsgr)p#v+bnc#cq1b_=q5_v-cx2!rer$-wyrqmv0&syr'
    enable :method_override
    set :app_file, __FILE__
    set :token_expire_days, 10
    set :token_secret, '3i#0hqc^rryl^bv$^cv0&z1s2%-=8)yv74_f@l#pgdwmsc_4p0'
    I18n.config.enforce_available_locales = true
  end

  configure :development do
    enable :logging, :dump_errors, :raise_errors
    set :force_ssl, false
    Mongoid.load!('config/mongoid.yml', :development)
  end

  configure :production do
    set :raise_errors, false
    set :show_exceptions, false
    set :force_ssl, false # TODO: set up SSL in Heroku
    Mongoid.load!('config/mongoid.yml', :production)
  end

  configure :localtest do
    enable :logging, :dump_errors, :raise_errors
    set :force_ssl, false
    Mongoid.load!('config/mongoid.yml', :localtest)
  end

  configure :remotetest do
    enable :logging, :raise_errors
    set :force_ssl, false
    Mongoid.load!('config/mongoid.yml', :remotetest)
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

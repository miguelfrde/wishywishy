require 'rubygems'
require 'bundler'
require 'sinatra'
require 'sinatra/json'
Bundler.require

API_VERSION = '1.0'

class WishyWishyApp < Sinatra::Base
  configure do
    # enable :sessions
    # set :session_secret, '*m!e-ypsgr)p#v+bnc#cq1b_=q5_v-cx2!rer$-wyrqmv0&syr'
    enable :method_override
    set :app_file, __FILE__
    set :token_expire_days, 10
    set :token_secret, '3i#0hqc^rryl^bv$^cv0&z1s2%-=8)yv74_f@l#pgdwmsc_4p0'
    Mongoid.load!('config/mongoid.yml', :development)
  end

  configure :development do
    enable :logging, :dump_errors, :raise_errors
    set :force_ssl, false
  end

  configure :production do
    set :raise_errors, false
    set :show_exceptions, false
    set :force_ssl, true
  end
end

require_relative 'models/init'
require_relative 'helpers/init'
require_relative 'routes/init'

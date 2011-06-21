if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'

get '/' do
  "Hello World"
end
require File.join(File.dirname(__FILE__), '..', 'server.rb')

require 'bundler'
require 'sinatra'
require 'rack/test'
require 'rspec'

# set test environment
set :environment, :test
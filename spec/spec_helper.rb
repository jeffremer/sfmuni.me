require File.join(File.dirname(__FILE__), '..', 'server.rb')

require 'bundler'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'webmock/rspec'
include WebMock

# set test environment
set :environment, :test
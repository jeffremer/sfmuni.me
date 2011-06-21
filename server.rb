if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'

get '/' do
  "Hello World"
end

post '/sms' do
  if valid_params? params
    status 200
  else
    status 400
  end
end 

def valid_params?(params)
  required_params = {
    :SmsSid => /\w{34}/,
    :AccountSid => /\w{34}/,
    :From => /^(\+1|1)?([2-9]\d\d[2-9]\d{6})$/,
    :To => /^(\+1|1)?([2-9]\d\d[2-9]\d{6})$/,
    :Body => /\w+/
  }
  required_params.each do |key, value|
      return false unless params[key]
      return false unless params[key] =~ required_params[key]
  end
end

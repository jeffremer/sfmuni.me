if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'
require 'muni'

get '/' do
  "Hello World"
end

post '/sms' do
  if valid? params
    route, direction, *stop = params[:Body].split(/\s+/)
    bus = Muni::Route.find(route)
    direction = bus.direction_at(direction)
    stop = direction.stop_at(stop.join(' '))
    "#{bus.title} #{direction.name} at #{stop.title}: #{stop.predictions.collect{|t|t.minutes + 'min'}.join(', ')}"
  else
    status 400    
  end
end 

def valid?(params)
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

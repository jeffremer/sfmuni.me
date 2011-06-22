if ENV['RACK_ENV'] != 'production'
  require 'rubygems'
end

require 'sinatra'
require 'muni'
require 'sass'

get '/' do
  haml :index
end

get '/app.css' do
  scss :app
end

post '/sms' do
  validations = valid?(params)
  if validations[:success]
    route, direction, *stop = params[:Body].split(/\s+/)
    bus = Muni::Route.find(route)
    direction = bus.direction_at(direction)
    stop = direction.stop_at(stop.join(' '))
    @msg = "#{bus.title} #{direction.name} at #{stop.title}: #{stop.predictions.collect{|t|t.minutes + 'min'}.join(', ')}"
    builder :sms   
  else
    status 400
    "400 Bad Request #{validations[:errors].join(', ')}"    
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
  errors = []
  required_params.each do |key, value|
      unless params[key]
        errors << "#{key} is required" 
        next
      end
      errors << "#{key} is invalid, got #{params[key]}" unless params[key] =~ required_params[key]
  end

  {:success => errors.empty?, :errors => errors}
end
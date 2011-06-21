require File.dirname(__FILE__) + '/spec_helper'

describe "SFMuni" do
  include Rack::Test::Methods
  
  def app
    @app ||= Sinatra::Application
  end
  
  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  describe "/sms" do
    pending "should respond ok with a valid Twilio request"
    pending "should respond bad requst with an invalid Twilio request"
  end
end
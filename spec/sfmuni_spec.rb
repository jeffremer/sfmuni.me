require File.dirname(__FILE__) + '/spec_helper'

describe "SFMuni" do
  include Rack::Test::Methods
  
  def app
    @app ||= Sinatra::Application
  end

  before(:each) do 
    @sms_params = {
      :SmsSid => (0...34).map{ ('a'..'z').to_a[rand(26)] }.join,
      :AccountSid => (0...34).map{ ('a'..'z').to_a[rand(26)] }.join,
      :From => '4155554567',
      :To => '4155554567',
      :Body => '21 inbound hayes and shrader'
    }
  end

  
  it "should respond to /" do
    get '/'
    last_response.should be_ok
  end
  
  describe "/sms" do
    it "should respond ok with a valid Twilio request" do
      post('/sms', @sms_params)
      last_response.should be_ok
      last_response.status.should == 200
    end
    it "should respond bad requst with an invalid Twilio request" do
      post('/sms', @sms_params.merge!({:Body => ''}))
      last_response.should_not be_successful
      last_response.status.should == 400      
    end
  end
end
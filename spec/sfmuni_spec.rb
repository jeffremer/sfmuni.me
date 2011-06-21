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
    describe "valid /sms request" do
      before(:each) do
        @route_url = "http://webservices.nextbus.com/service/publicXMLFeed?command=routeConfig&a=sf-muni&r=21"
        stub_request(:get, @route_url).to_return(:body => File.open(File.join(File.dirname(__FILE__),"fixtures", "21_route_config.xml"), "rb").read)
        @predictions_url = "http://webservices.nextbus.com/service/publicXMLFeed?a=sf-muni&command=predictions&d=21_IB1&r=21&s=7561"
        stub_request(:get, @predictions_url).
          to_return(:status => 200, :body => File.open(File.join(File.dirname(__FILE__),"fixtures", "21_predictions.xml"), "rb").read)
      end
      it "should respond ok" do
        post('/sms', @sms_params)
        last_response.should be_ok
        last_response.status.should == 200
      
        WebMock.should have_requested(:get, @route_url)
        WebMock.should have_requested(:get, @predictions_url)
      end
    
      it "should respond with predictions" do
        post('/sms', @sms_params)      
        last_response.body.should == "21-Hayes Inbound to Steuart Terminal at Hayes St & Shrader St: 1min, 11min, 31min, 41min, 54min"
        WebMock.should have_requested(:get, @route_url)
        WebMock.should have_requested(:get, @predictions_url)        
      end
    end

    describe "invalid /sms request" do
      it "should respond bad requst with an invalid Twilio request" do
        post('/sms', @sms_params.merge!({:Body => ''}))
        last_response.should_not be_successful
        last_response.status.should == 400      
      end
      
      it "should not respond to GET" do
        get('/sms')
        last_response.should_not be_successful
      end      
    end
  end
end
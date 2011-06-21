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
          
        @sms_url = "https://AP1e8fbfc113ec44360d58ee9f2795df61:c6659ca02a3c5cba21dc175802b5b1f3@api.twilio.com/2010-04-01/Accounts/AP1e8fbfc113ec44360d58ee9f2795df61/SMS/Messages"
        stub_request(:post, @sms_url).
                 with(:body => "From=%2b14159686488&To=4155554567&Body=21-Hayes%20Inbound%20to%20Steuart%20Terminal%20at%20Hayes%20St%20%26%20Shrader%20St%3a%201min%2c%2011min%2c%2031min%2c%2041min%2c%2054min", 
                      :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
                 to_return(:status => 200, :body => "", :headers => {})
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
      
      it "should SMS predictions to the To number" do
        post('/sms', @sms_params)      
        last_response.body.should == "21-Hayes Inbound to Steuart Terminal at Hayes St & Shrader St: 1min, 11min, 31min, 41min, 54min"
        WebMock.should have_requested(:get, @route_url)
        WebMock.should have_requested(:get, @predictions_url)
        WebMock.should have_requested(:post, @sms_url)
      end
    end

    describe "invalid /sms request" do
      it "should respond bad requst with an invalid Twilio request" do
        post('/sms', @sms_params.merge!({:Body => nil}))
        last_response.should_not be_successful
        last_response.status.should == 400      
        last_response.body.should == "400 Bad Request Body is required"
      end
      
      it "should not respond to GET" do
        get('/sms')
        last_response.should_not be_successful
      end      
    end
  end
end
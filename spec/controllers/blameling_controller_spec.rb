require 'spec_helper'

describe RailsApp do
  controller(RailsApp::BlamelingController) do
    extend(RSpec::Rails::ControllerExampleGroup::BypassRescue)
  end

  before(:each) do
    # Request needs to be setup to avoid path setting error
    @request = ActionController::TestRequest.new
  end

  it "should set current_user if Blameling is included" do
    Thread.new {
      post :create
      # Look in application.rb for the User class and it's id method.
      BlogPost.last.all_history.last.modified_by.should == 33
    }.join
  end
end

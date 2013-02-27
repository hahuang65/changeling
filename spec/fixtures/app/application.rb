require 'spec_helper'

module RailsApp
  class Application < Rails::Application
  end

  class ApplicationController < ActionController::Base
    def render(*attributes)
      # Override render so we don't have to deal with rendering in tests.
    end

    def current_user
      User.new
    end
  end

  class User
    def id
      33
    end
  end
end

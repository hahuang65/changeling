require 'spec_helper'

module RailsApp
  class Application < Rails::Application
    # app config here
    # config.secret_token = '572c86f5ede338bd8aba8dae0fd3a326aabababc98d1e6ce34b9f5'
    # routes.draw do
    #   resources :blog_posts
    # end
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

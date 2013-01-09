module Changeling
  class Engine < Rails::Engine
    initializer"changeling.load_helper" do
      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.helper Changeling::Support::Helpers
      end
    end
  end
end

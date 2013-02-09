require (File.expand_path('../no_current_user_controller', __FILE__))

module RailsApp
  class CurrentAccountController < NoCurrentUserController
    def changeling_blame_user
      current_account
    end

    def current_account
      Account.new
    end
  end

  class Account
    def id
      88
    end
  end
end

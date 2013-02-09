require (File.expand_path('../blameling_controller', __FILE__))

module RailsApp
  class NoCurrentUserController < BlamelingController
    undef :current_user
  end
end

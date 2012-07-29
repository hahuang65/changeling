require "changeling/version"

module Changeling
  autoload :Trackling, 'changeling/trackling'
  autoload :Scanling, 'changeling/scanling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end
end

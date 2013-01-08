require 'rubygems'
require 'tire'
require "changeling/version"

module Changeling
  Tire::Model::Search.index_prefix "changeling"

  autoload :Trackling, 'changeling/trackling'
  autoload :Probeling, 'changeling/probeling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end

  module Support
    autoload :Search, 'changeling/support/search'
    require 'changeling/support/helpers'
  end
end

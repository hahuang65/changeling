require 'rubygems'
require 'tire'
require "changeling/version"

module Changeling
  Tire::Model::Search.index_prefix "changeling"

  require 'changeling/engine' if defined?(Rails::Engine)

  autoload :Trackling, 'changeling/trackling'
  autoload :Probeling, 'changeling/probeling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end

  module Support
    autoload :Search, 'changeling/support/search'
    autoload :Helpers, 'changeling/support/helpers'
  end
end

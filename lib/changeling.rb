require 'rubygems'
require 'tire'
require "changeling/version"

module Changeling
  Tire::Model::Search.index_prefix "Changeling"

  autoload :Trackling, 'changeling/trackling'
  autoload :Probeling, 'changeling/probeling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end
end

require 'rubygems'
require 'redis'
require "changeling/version"

module Changeling
  autoload :Trackling, 'changeling/trackling'
  autoload :Probeling, 'changeling/probeling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end
end

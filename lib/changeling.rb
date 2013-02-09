require 'rubygems'
require 'tire'
require "changeling/version"

module Changeling
  Tire::Model::Search.index_prefix "changeling"

  autoload :Trackling, 'changeling/trackling'
  autoload :Probeling, 'changeling/probeling'
  autoload :Blameling, 'changeling/blameling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end

  module Support
    autoload :Search, 'changeling/support/search'
  end

  def self.blame_user
    self.changeling_store[:blame_user]
  end

  def self.blame_user=(user)
    self.changeling_store[:blame_user] = user
  end

  private
    def self.changeling_store
      Thread.current[:changeling] ||= {
        :blame_user => nil
      }
    end
end

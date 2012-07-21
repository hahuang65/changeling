require "changeling/version"

module Changeling
  autoload :Trackling, 'changeling/trackling'

  module Models
    autoload :Logling, 'changeling/models/logling'
  end

  def redis
    @redis ||= Redis.new
  end
end

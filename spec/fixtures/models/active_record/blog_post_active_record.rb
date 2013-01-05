require 'rubygems'
require 'active_record'

class BlogPostActiveRecord < ActiveRecord::Base
  include Changeling::Trackling
  include Changeling::Probeling
end

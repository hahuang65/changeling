# Setup for the fields etc. happens in spec_helper.
class BlogPostActiveRecord < ActiveRecord::Base
  include Changeling::Trackling
  include Changeling::Probeling
end

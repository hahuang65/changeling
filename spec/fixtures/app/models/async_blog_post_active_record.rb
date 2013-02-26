# Setup for the fields etc. happens in spec_helper.
class AsyncBlogPostActiveRecord < ActiveRecord::Base
  include Changeling::Async::Trackling
  include Changeling::Probeling
end

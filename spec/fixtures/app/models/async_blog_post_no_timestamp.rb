class AsyncBlogPostNoTimestamp
  include Mongoid::Document
  include Changeling::Async::Trackling
  include Changeling::Probeling

  field :title
  field :content
  field :public, :type => Boolean
end

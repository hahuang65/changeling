class AsyncBlogPost
  include Mongoid::Document
  include Mongoid::Timestamps
  include Changeling::Async::Trackling
  include Changeling::Probeling

  field :title
  field :content
  field :public, :type => Boolean
end

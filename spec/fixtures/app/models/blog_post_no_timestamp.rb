class BlogPostNoTimestamp
  include Mongoid::Document
  include Changeling::Trackling
  include Changeling::Probeling

  field :title
  field :content
  field :public, :type => Boolean
end

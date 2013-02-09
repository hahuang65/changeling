class BlogPost
  include Mongoid::Document
  include Mongoid::Timestamps
  include Changeling::Trackling
  include Changeling::Probeling

  field :title
  field :content
  field :public, :type => Boolean
end

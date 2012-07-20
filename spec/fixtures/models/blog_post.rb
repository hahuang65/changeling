class BlogPost
  include Mongoid::Document
  include Changeling::Trackling

  field :title
  field :content
  field :public, :type => Boolean
end

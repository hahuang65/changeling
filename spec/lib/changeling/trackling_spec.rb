require (File.expand_path('../../../spec_helper', __FILE__))

describe Changeling::Trackling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  before(:each) do
    @blog_post = BlogPost.new(:title => "Changeling", :content => "Something about Changeling", :public => false)
  end

  it "should not create a logling when doing the initial save of a new object" do
    @klass.should_not_receive(:create)
    @blog_post.save!
  end

  it "should create a logling with the changed attributes of an object when it is saved" do
    # Persist object to DB so we can update it.
    @blog_post.save!

    @klass.should_receive(:create).with(@blog_post, { "public" => [false, true], "content" => ["Something about Changeling", "Content about Changeling"] })
    @blog_post.public = true
    @blog_post.content = "Content about Changeling"
    @blog_post.save!
  end
end

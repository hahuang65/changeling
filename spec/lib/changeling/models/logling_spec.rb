require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Models::Logling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  describe ".create" do
    before(:each) do
      @blog_post = BlogPost.new
      @changes = { "public" => [false, true], "content" => ["Something about Changeling", "Content about Changeling"] }
      @blog_post.stub(:changes).and_return(@changes)

      @logling = @klass.new
      @klass.should_receive(:new).with(@blog_post, @changes).and_return(@logling)
    end

    it "should call new with it's parameters then save the initialized logling" do
      @logling.should_receive(:save)

      @klass.create(@blog_post, @changes)
    end
  end
end

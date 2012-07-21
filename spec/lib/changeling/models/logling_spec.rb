require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Models::Logling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  describe ".new" do
    before(:each) do
      @blog_post = BlogPost.new
      @changes = { "public" => [false, true], "content" => ["Something about Changeling", "Content about Changeling"] }

      @before, @after = @klass.parse_changes(@changes)

      @logling = @klass.new(@blog_post, @changes)
    end

    it "should set klass as the pluralized version of the class name" do
      @logling.klass.should == @blog_post.class.to_s.underscore.pluralize
    end

    it "should set object_id as the stringified object's ID" do
      @logling.object_id.should == @blog_post.id.to_s
    end

    it "should set before and after based on .parse_changes" do
      @logling.before.should == @before
      @logling.after.should == @after
    end
  end

  describe ".create" do
    before(:each) do
      @blog_post = BlogPost.new
      @changes = { "public" => [false, true], "content" => ["Something about Changeling", "Content about Changeling"] }
      @blog_post.stub(:changes).and_return(@changes)

      @logling = @klass.new(@blog_post, @changes)
      @klass.should_receive(:new).with(@blog_post, @changes).and_return(@logling)
    end

    it "should call new with it's parameters then save the initialized logling" do
      @logling.should_receive(:save)

      @klass.create(@blog_post, @changes)
    end
  end

  describe ".parse_changes" do
    before(:each) do
      @blog_post = BlogPost.create(:title => "Changeling", :content => "Something about Changeling", :public => false)

      @before = @blog_post.attributes.select { |attr| attr == "content" }

      @blog_post.content = "Content about Changeling"

      @after = @blog_post.attributes.select { |attr| attr == "content" }

    end

    it "should correctly match the before and after states of the object" do
      @klass.parse_changes(@blog_post.changes).should == [@before, @after]
    end
  end
end

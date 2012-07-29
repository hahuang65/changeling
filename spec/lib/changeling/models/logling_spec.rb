require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Models::Logling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  # .models is defined in spec_helper.
  models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
      @changes = args[:changes]

      @logling = @klass.new(@object, @changes)
    end

    describe ".as_json" do
      it "should include the object's modifications attribute" do
        @logling.should_receive(:modifications)
      end

      it "should include the object's changed_at attribute" do
        @logling.should_receive(:changed_at)
      end

      after(:each) do
        @logling.as_json
      end
    end

    describe ".create" do
      before(:each) do
        @object.stub(:changes).and_return(@changes)

        @klass.should_receive(:new).with(@object, @changes).and_return(@logling)
      end

      it "should call new with it's parameters then save the initialized logling" do
        @logling.should_receive(:save)

        @klass.create(@object, @changes)
      end
    end

    describe ".new" do
      before(:each) do
        @before, @after = @klass.parse_changes(@changes)
      end

      it "should set klass as the pluralized version of the class name" do
        @logling.klass.should == @object.class.to_s.underscore.pluralize
      end

      it "should set object_id as the stringified object's ID" do
        @logling.object_id.should == @object.id.to_s
      end

      it "should set the modifications as the incoming changes parameter" do
        @logling.modifications.should == @changes
      end

      it "should set before and after based on .parse_changes" do
        @logling.before.should == @before
        @logling.after.should == @after
      end

      it "should set changed_at to the object's time of update" do
        @logling.changed_at.should == @object.updated_at
      end
    end

    describe ".parse_changes" do
      before(:each) do
        @object.save!

        @before = @object.attributes.select { |attr| @changes.keys.include?(attr) }

        @changes.each_pair do |k, v|
          @object.send("#{k}=", v[1])
        end

        @after = @object.attributes.select { |attr| @changes.keys.include?(attr) }
      end

      it "should correctly match the before and after states of the object" do
        @klass.parse_changes(@object.changes).should == [@before, @after]
      end
    end

    describe ".redis_key" do
      it "should consist of 3 parts, changeling::model_name::object_id" do
        @logling.redis_key.should == "changeling::#{@object.class.to_s.underscore.pluralize}::#{@object.id.to_s}"
      end
    end

    describe ".save" do
      before(:each) do
        @redis = Redis.new(:db => 1)
        Changeling.stub(:redis).and_return(@redis)
      end

      it "should generate a key for storing in Redis" do
        @logling.should_receive(:redis_key)
      end

      it "should serialize the logling" do
        @logling.should_receive(:serialize)
      end

      it "should push the serialized object into Redis" do
        @key = 1
        @value = 2
        @logling.stub(:redis_key).and_return(@key)
        @logling.stub(:serialize).and_return(@value)
        @redis.should_receive(:lpush).with(@key, @value)
      end

      after(:each) do
        @logling.save
      end
    end

    describe ".serialize" do
      it "should JSON-ify the as_json object" do
        @logling.serialize.should == @logling.as_json.to_json
      end
    end
  end
end

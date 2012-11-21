require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Models::Logling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  # .models is defined in spec_helper.
  models.each_pair do |model, args|
    puts "Testing #{model} now."

    before(:each) do
      @object = model.new(args[:options])
      @changes = args[:changes]

      @logling = @klass.new(@object, @changes)
    end

    context "Class Methods" do
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

        it "should set klass as the .klassify-ed value" do
          @logling.klass.should == @klass.klassify(@object)
        end

        it "should set oid as the stringified object's ID" do
          @logling.oid.should == @object.id.to_s
        end

        it "should set the modifications as the incoming changes parameter" do
          @logling.modifications.should == @changes
        end

        it "should set before and after based on .parse_changes" do
          @logling.before.should == @before
          @logling.after.should == @after
        end

        it "should set changed_at to the object's time of update if the object responds to the updated_at method" do
          @object.should_receive(:respond_to?).with(:updated_at).and_return(true)

          # Setting up a variable to prevent test flakiness from passing time.
          time = Time.now
          @object.stub(:updated_at).and_return(time)

          # Create a new logling to trigger the initialize method
          @logling = @klass.new(@object, @changes)
          @logling.changed_at.should == @object.updated_at
        end

        it "should set changed_at to the current time if the object doesn't respond to updated_at" do
          @object.should_receive(:respond_to?).with(:updated_at).and_return(false)

          # Setting up a variable to prevent test flakiness from passing time.
          time = Time.now
          Time.stub(:now).and_return(time)

          # Create a new logling to trigger the initialize method
          @logling = @klass.new(@object, @changes)
          @logling.changed_at.should == time
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

      describe ".klassify" do
        it "should return the underscored version of the objects class as a string" do
          @klass.klassify(@object).should == @object.class.to_s.underscore
        end
      end

      describe ".records_for" do
        it "should find the length of the Redis list" do
          @key = @logling.redis_key
          @klass.stub(:redis_key).and_return(@key)
          $redis.should_receive(:llen).with(@key)
          @klass.records_for(@object)
        end

        it "should not find the length of the Redis list if length option is passed" do
          @key = @logling.redis_key
          @klass.stub(:redis_key).and_return(@key)
          $redis.should_not_receive(:llen).with(@key)
          @klass.records_for(@object, 10)
        end

        it "should find all entries in the Redis list" do
          @key = @logling.redis_key
          @length = 100
          @klass.stub(:redis_key).and_return(@key)
          $redis.stub(:llen).and_return(@length)
          $redis.should_receive(:lrange).with(@key, 0, @length).and_return([])
          @klass.records_for(@object)
        end

        it "should find the specified amount of entries in the Redis list if length option is passed" do
          @key = @logling.redis_key
          @klass.stub(:redis_key).and_return(@key)
          $redis.should_receive(:lrange).with(@key, 0, 5).and_return([])
          @klass.records_for(@object, 5)
        end
      end
    end

    context "Instance Methods" do
      describe ".to_indexed_json" do
        it "should include the object's klass attribute" do
          @logling.should_receive(:klass)
        end

        it "should include the object's oid attribute" do
          @logling.should_receive(:oid)
        end

        it "should include the object's modifications attribute" do
          @logling.should_receive(:modifications)
        end

        it "should include the object's changed_at attribute" do
          @logling.should_receive(:changed_at)
        end

        after(:each) do
          @logling.to_indexed_json
        end
      end

      describe ".save" do
        it "should update the ElasticSearch index" do
          @logling.should_receive(:update_elasticsearch_index)
        end

        after(:each) do
          @logling.save
        end
      end
    end
  end
end

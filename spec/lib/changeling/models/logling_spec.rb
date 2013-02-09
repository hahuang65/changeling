require 'spec_helper'

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

      @object.stub(:changes).and_return(@changes)
      @logling = @klass.new(@object)
    end

    context "Class Methods" do
      describe ".create" do
        before(:each) do

          @klass.should_receive(:new).with(@object).and_return(@logling)
        end

        it "should call new with it's parameters then save the initialized logling" do
          @logling.should_receive(:save)

          @klass.create(@object)
        end
      end

      describe ".new" do
        context "when passed object is a ElasticSearch response hash" do
          before(:each) do
            @object = {
              "klass"=>"BlogPost",
              "oid"=>"50b8355f7a93d04908000001",
              "modifications"=>"{\"public\":[true,false]}",
              "modified_at"=>"2012-11-29T20:26:07-08:00"
            }

            @logling = @klass.new(@object)
            @changes = JSON.parse(@object['modifications'])
            @before, @after = @klass.parse_changes(@changes)
            @modified_time = DateTime.parse(@object['modified_at'])
          end

          it "should set klass as the returned klass value" do
            @logling.klass.should == @object['klass'].constantize
          end

          it "should set oid as the returned oid value" do
            @logling.oid.should == @object['oid']
          end

          it "should convert oid to an integer if it's supposed to be an integer" do
            @object["oid"] = "1"
            @klass.new(@object).oid.should == @object["oid"].to_i
          end

          it "should set the modifications as the incoming changes parameter" do
            @logling.modifications.should == @changes
          end

          it "should set the modified_fields as the keys of the modifications" do
            @logling.modified_fields.should == @changes.keys
          end

          it "should set before and after based on .parse_changes" do
            @logling.before.should == @before
            @logling.after.should == @after
          end

          it "should set modified_at as the parsed version of the returned modified_at value" do
            @logling.modified_at.should == @modified_time
          end
        end

        context "when passed object is a real object" do
          before(:each) do
            @before, @after = @klass.parse_changes(@changes)
          end

          it "should set klass as the object's class" do
            @logling.klass.should == @object.class
          end

          it "should set oid as the object's ID" do
            @logling.oid.should == @object.id
          end

          it "should set the modifications as the incoming changes parameter" do
            @logling.modifications.should == @changes
          end

          it "should set before and after based on .parse_changes" do
            @logling.before.should == @before
            @logling.after.should == @after
          end

          it "should set the modified_fields as the keys of the modifications" do
            @logling.modified_fields.should == @changes.keys
          end

          it "should ignore changes that are nil" do
            changes = {}

            @changes.keys.each do |key|
              changes[key] = nil
            end

            @object.stub(:changes).and_return(changes)

            @klass.new(@object).modifications.should be_empty
          end

          it "should set modified_at to the object's time of update if the object responds to the updated_at method" do
            @object.should_receive(:respond_to?).with(:updated_at).and_return(true)

            # Setting up a variable to prevent test flakiness from passing time.
            time = Time.now
            @object.stub(:updated_at).and_return(time)

            # Create a new logling to trigger the initialize method
            @logling = @klass.new(@object)
            @logling.modified_at.should == @object.updated_at
          end

          it "should set modified_at to the current time if the object doesn't respond to updated_at" do
            @object.should_receive(:respond_to?).with(:updated_at).and_return(false)

            # Setting up a variable to prevent test flakiness from passing time.
            time = Time.now
            Time.stub(:now).and_return(time)

            # Create a new logling to trigger the initialize method
            @logling = @klass.new(@object)
            @logling.modified_at.should == time
          end
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
        it "should return the object's class as an underscored string" do
          @klass.klassify(@object).should == @object.class.to_s.underscore
        end
      end

      describe ".records_for" do
        before(:each) do
          @search = Changeling::Support::Search
          @results = []
        end

        context "length parameter" do
          before(:each) do
            @search.stub(:find_by).and_return(@results)
          end

          it "should only return the amount specified" do
            num = 5
            @results.should_receive(:take).with(num).and_return([])
            @klass.records_for(@object, 5)
          end

          it "should return all if no amount is specified" do
            @results.should_not_receive(:take)
            @klass.records_for(@object)
          end
        end

        it "should search with filters on the klass and oid" do
          @search.should_receive(:find_by).with(hash_including({
            :filters => [
              { :klass => @klass.klassify(@object) },
              { :oid => @object.id.to_s }
            ]
          })).and_return(@results)
          @klass.records_for(@object)
        end

        it "should search with a filter on the field if one is passed in" do
          @search.should_receive(:find_by).with(hash_including(
            :filters => [
              { :klass => @klass.klassify(@object) },
              { :oid => @object.id.to_s },
              { :modified_fields => "field" }
            ]
          )).and_return(@results)
          @klass.records_for(@object, nil, "field")
        end

        it "should sort by descending modified_at" do
          @search.should_receive(:find_by).with(hash_including({
            :sort => {
              :field => :modified_at,
              :direction => :desc
            }
          })).and_return(@results)
          @klass.records_for(@object, nil)
        end
      end
    end

    context "Instance Methods" do
      before(:each) do
        # Stub :id so that it doesn't screw up these test's expectations.
        @logling.stub(:id).and_return(1)
      end

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

        it "should convert the object's modifications attribute to JSON" do
          mods = {}
          @logling.should_receive(:modifications).and_return(mods)
          mods.should_receive(:to_json)
        end

        it "should include the object's modified_at attribute" do
          @logling.should_receive(:modified_at)
        end

        it "should include an array of the object's modified fields" do
          @logling.should_receive(:modified_fields)
        end

        after(:each) do
          @logling.to_indexed_json
        end
      end

      describe ".as_json" do
        before(:each) do
          @json = @logling.as_json
        end

        it "should include the object's klass attribute" do
          @json[:class].should == @object.class
        end

        it "should include the object's oid attribute" do
          @json[:oid].should == @object.id
        end

        it "should include the object's modifications attribute" do
          @json[:modifications].should == @changes
        end

        it "should include the object's modified_at attribute" do
          @json[:modified_at].should == @logling.modified_at
        end

        after(:each) do
          @logling.to_indexed_json
        end
      end

      describe ".save" do
        it "should update the ElasticSearch index" do
          @logling.should_receive(:update_index)
        end

        it "should not update the index if there are no changes" do
          @logling.stub(:modifications).and_return({})
          @logling.should_not_receive(:_run_save_callbacks)
        end

        after(:each) do
          @logling.save
        end
      end
    end
  end
end

require 'spec_helper'

describe Changeling::Models::Logling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  # .models is defined in spec_helper.
  models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
      @changes = args[:changes]

      allow(@object).to receive(:changes).and_return(@changes)
      @logling = @klass.new(@object)
    end

    context "#{model}" do
      context "Class Methods" do
        describe ".create" do
          before(:each) do
            expect(@klass).to receive(:new).with(@object).and_return(@logling)
          end

          it "should call new with it's parameters then save the initialized logling" do
            expect(@logling).to receive(:save)

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
              expect(@logling.klass).to eq(@object['klass'].constantize)
            end

            it "should set oid as the returned oid value" do
              expect(@logling.oid).to eq(@object['oid'])
            end

            it "should convert oid to an integer if it's supposed to be an integer" do
              @object["oid"] = "1"
              expect(@klass.new(@object).oid).to eq(@object["oid"].to_i)
            end

            it "should set the modifications as the incoming changes parameter" do
              expect(@logling.modifications).to eq(@changes)
            end

            it "should set the modified_fields as the keys of the modifications" do
              expect(@logling.modified_fields).to eq(@changes.keys)
            end

            it "should set before and after based on .parse_changes" do
              expect(@logling.before).to eq(@before)
              expect(@logling.after).to eq(@after)
            end

            it "should set modified_at as the parsed version of the returned modified_at value" do
              expect(@logling.modified_at).to eq(@modified_time)
            end
          end

          context "when passed object is a real object" do
            before(:each) do
              @before, @after = @klass.parse_changes(@changes)
            end

            it "should set klass as the object's class" do
              expect(@logling.klass).to eq(@object.class)
            end

            it "should set oid as the object's ID" do
              expect(@logling.oid).to eq(@object.id)
            end

            it "should set the modifications as the incoming changes parameter" do
              expect(@logling.modifications).to eq(@changes)
            end

            it "should set before and after based on .parse_changes" do
              expect(@logling.before).to eq(@before)
              expect(@logling.after).to eq(@after)
            end

            it "should set the modified_fields as the keys of the modifications" do
              expect(@logling.modified_fields).to eq(@changes.keys)
            end

            it "should ignore changes that are nil" do
              changes = {}

              @changes.keys.each do |key|
                changes[key] = nil
              end

              allow(@object).to receive(:changes).and_return(changes)

              expect(@klass.new(@object).modifications).to be_empty
            end

            it "should set modified_at to the object's time of update if the object responds to the updated_at method" do
              # Setting up a variable to prevent test flakiness from passing time.
              time = Time.now
              allow(@object).to receive(:updated_at).and_return(time)
              expect(@object).to receive(:respond_to?).with(:updated_at).and_return(true)

              # Create a new logling to trigger the initialize method
              @logling = @klass.new(@object)
              expect(@logling.modified_at).to eq(@object.updated_at)
            end

            it "should set modified_at to the current time if the object doesn't respond to updated_at" do
              expect(@object).to receive(:respond_to?).with(:updated_at).and_return(false)

              # Setting up a variable to prevent test flakiness from passing time.
              time = Time.now
              allow(Time).to receive(:now).and_return(time)

              # Create a new logling to trigger the initialize method
              @logling = @klass.new(@object)
              expect(@logling.modified_at).to eq(time)
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
            expect(@klass.parse_changes(@object.changes)).to eq([@before, @after])
          end
        end

        describe ".klassify" do
          it "should return the object's class as an underscored string" do
            expect(@klass.klassify(@object)).to eq(@object.class.to_s.underscore)
          end
        end

        describe ".records_for" do
          before(:each) do
            @search = Changeling::Support::Search
            @results = []
          end

          context "length parameter" do
            before(:each) do
              allow(@search).to receive(:find_by).and_return(@results)
            end

            it "should be passed into the Search module" do
              num = 5
              expect(@search).to receive(:find_by).with(hash_including({ :size => num })).and_return(@results)
              @klass.records_for(@object, 5)
            end

            it "should pass nil for size option into Search module" do
              expect(@search).to receive(:find_by).with(hash_including({ :size => nil })).and_return(@results)
              @klass.records_for(@object)
            end
          end

          it "should search with filters on the klass and oid" do
            expect(@search).to receive(:find_by).with(hash_including({
              :filters => [
                { :klass => @klass.klassify(@object) },
                { :oid => @object.id.to_s }
              ]
            })).and_return(@results)
            @klass.records_for(@object)
          end

          it "should search with a filter on the field if one is passed in" do
            expect(@search).to receive(:find_by).with(hash_including(
              :filters => [
                { :klass => @klass.klassify(@object) },
                { :oid => @object.id.to_s },
                { :modified_fields => "field" }
              ]
            )).and_return(@results)
            @klass.records_for(@object, nil, "field")
          end

          it "should sort by descending modified_at" do
            expect(@search).to receive(:find_by).with(hash_including({
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
          allow(@logling).to receive(:id).and_return(1)
        end

        describe ".to_indexed_json" do
          it "should include the object's klass attribute" do
            expect(@logling).to receive(:klass)
          end

          it "should include the object's oid attribute" do
            expect(@logling).to receive(:oid)
          end

          it "should include the object's modifications attribute" do
            expect(@logling).to receive(:modifications)
          end

          it "should convert the object's modifications attribute to JSON" do
            mods = {}
            expect(@logling).to receive(:modifications).and_return(mods)
            expect(mods).to receive(:to_json)
          end

          it "should include the object's modified_at attribute" do
            expect(@logling).to receive(:modified_at)
          end

          it "should include an array of the object's modified fields" do
            expect(@logling).to receive(:modified_fields)
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
            expect(@json[:class]).to eq(@object.class)
          end

          it "should include the object's oid attribute" do
            expect(@json[:oid]).to eq(@object.id)
          end

          it "should include the object's modifications attribute" do
            expect(@json[:modifications]).to eq(@changes)
          end

          it "should include the object's modified_at attribute" do
            expect(@json[:modified_at]).to eq(@logling.modified_at)
          end

          after(:each) do
            @logling.to_indexed_json
          end
        end

        describe ".save" do
          it "should update the ElasticSearch index" do
            expect(@logling).to receive(:update_index)
          end

          it "should not update the index if there are no changes" do
            allow(@logling).to receive(:modifications).and_return({})
            expect(@logling).not_to receive(:_run_save_callbacks)
          end

          after(:each) do
            @logling.save
          end
        end
      end
    end
  end
end

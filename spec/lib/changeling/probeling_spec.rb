require 'spec_helper'

describe Changeling::Probeling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
      @object.save!

      args[:changes].each do |field, values|
        values.reverse.each do |value|
          @object.send("#{field}=", value)
          @object.save!
        end
      end

      @object.loglings.count.should == 4
    end
  end

  describe "pagination" do
    before(:each) do
      (1..50).each do |num|
        @object.title = "Title #{num}"
        @object.save!
      end
    end

    it "should return the specified amount of data when calling .loglings" do
      @object.loglings.count.should == 10
      @object.loglings(60).count.should == 54
    end
  end

  describe ".loglings" do
    it "should query Logling with it's class name, and it's own ID, and a default number of loglings to return" do
      @klass.should_receive(:records_for).with(@object, 10)
      @object.loglings
    end

    it "should take an argument that overrides the default" do
      @klass.should_receive(:records_for).with(@object, 5)
      @object.loglings(5)
    end

    it "should handle non-integer arguments" do
      @klass.should_receive(:records_for).with(@object, 5)
      @object.loglings("5")
    end

    it "should only return the amount of loglings requested" do
      @object.loglings(2).count.should == 2
    end

    it "should not error out if the record count desired is more than the total number of loglings" do
      @object.loglings(20).count.should == 4
    end
  end

  describe ".loglings_for_field" do
    it "should query Logling with it's class name, and it's own ID, a field name, and a default number of loglings to return" do
      @klass.should_receive(:records_for).with(@object, 10, "field")
      @object.loglings_for_field("field")
    end

    it "should be able to take a length to specify amount of loglings to return" do
      @klass.should_receive(:records_for).with(@object, 5, "field")
      @object.loglings_for_field("field", 5)
    end

    it "should handle non-integer arguments for length" do
      @klass.should_receive(:records_for).with(@object, 5, "field")
      @object.loglings_for_field("field", "5")
    end

    it "should handle symbol arguments for field" do
      @klass.should_receive(:records_for).with(@object, 10, "field")
      @object.loglings_for_field(:field)
    end

    it "should only return loglings where the specified field has changed" do
      models.values.each do |value|
        value[:changes].keys.each do |field|
          @object.loglings_for_field(field).each do |logling|
            logling.modifications.keys.should include(field)
          end

          @object.loglings_for_field(field).count.should == 2
        end
      end
    end

    it "should be able to find loglings even if there was more than one change logged in the logling" do
      models.each_pair do |model, args|
        @object = model.new(args[:options])
        @object.save!

        args[:changes].each do |field, values|
          values.reverse.each do |value|
            @object.send("#{field}=", value)
            @object.save!
            # Sleep to guarantee saves are not within the same second.
            sleep 1
          end
        end

        # This should make 2 changes at the same time then save it
        args[:changes].each do |field, values|
          @object.send("#{field}=", values.last)
        end

        @object.save!
      end

      models.values.each do |value|
        value[:changes].keys.each do |field|
          # Reverse chronological order: first object is the last inserted, which should have 2 changes.
          # The last object should have 1 change.
          @object.loglings_for_field(field).last.modifications.keys.count.should == 1
          @object.loglings_for_field(field).first.modifications.keys.count.should == 2

          @object.loglings_for_field(field).count.should == 3
        end
      end
    end

    it "should only return the specified amount of loglings" do
      models.values.each do |value|
        value[:changes].keys.each do |field|
          @object.loglings_for_field(field).count.should == 2
          @object.loglings_for_field(field, 1).count.should == 1
        end
      end
    end

    it "should not error out if the record count desired is more than the total number of loglings" do
      models.values.each do |value|
        value[:changes].keys.each do |field|
          @object.loglings_for_field(field).count.should == 2
          @object.loglings_for_field(field, 10).count.should == 2
        end
      end
    end
  end
end

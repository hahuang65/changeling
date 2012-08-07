require (File.expand_path('../../../spec_helper', __FILE__))

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

      @object.all_history.count.should == 4
    end
  end

  describe ".all_history" do
    it "should query Logling with it's pluralized class name, and it's own ID" do
      @klass.should_receive(:records_for).with(@object)
      @object.all_history
    end

    it "should return an array of Loglings" do
      @object.all_history.map(&:class).uniq.should == [@klass]
    end
  end

  describe ".history" do
    it "should query Logling with it's pluralized class name, and it's own ID, and a default number of loglings to return" do
      @klass.should_receive(:records_for).with(@object, 10)
      @object.history
    end

    it "should take an argument that overrides the default" do
      @klass.should_receive(:records_for).with(@object, 5)
      @object.history(5)
    end

    it "should handle non-integer arguments" do
      @klass.should_receive(:records_for).with(@object, 5)
      @object.history("5")
    end

    it "should not error out if the record count desired is more than the total number of loglings" do
      @object.history(20).count.should == 4
    end
  end
end

require (File.expand_path('../../../spec_helper', __FILE__))

describe Changeling::Scanling do
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

      @object.all_loglings.count.should == 4
    end
  end

  describe ".all_loglings" do
    it "should query Logling with it's pluralized class name, and it's own ID" do
      @klass.should_receive(:records_for).with(@object)
      @object.all_loglings
    end

    it "should return an array of Loglings" do
      @object.all_loglings.map(&:class).uniq.should == [@klass]
    end
  end
end

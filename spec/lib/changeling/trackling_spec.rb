require (File.expand_path('../../../spec_helper', __FILE__))

describe Changeling::Trackling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
    end

    describe "callbacks" do
      before(:each) do
        @changes = args[:changes]
      end

      it "should not create a logling when doing the initial save of a new object" do
        @klass.should_not_receive(:create)
        @object.save!
      end

      it "should create a logling with the changed attributes of an object when it is saved" do
        # Persist object to DB so we can update it.
        @object.save!

        @klass.should_receive(:create).with(@object, @changes)

        @changes.each_pair do |k, v|
          @object.send("#{k}=", v[1])
        end

        @object.save!
      end
    end

    describe "instance methods" do
    end
  end
end

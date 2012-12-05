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
      it "should not create a logling when doing the initial save of a new object" do
        @klass.should_not_receive(:create)
        @object.run_after_callbacks(:create)
      end

      it "should create a logling when updating an object and changes are made" do
        @klass.should_receive(:create)
        @object.stub(:changes).and_return({ :field => 'value' })
        @object.run_after_callbacks(:update)
      end

      it "should create a logling when updating an object and changes are empty" do
        @klass.should_not_receive(:create)
        @object.stub(:changes).and_return({})
        @object.run_after_callbacks(:update)
      end

      it "should not create a logling when updating an object and no changes have been made" do
        @klass.should_not_receive(:create)
        @object.stub(:changes).and_return(nil)
        @object.run_after_callbacks(:update)
      end
    end
  end
end

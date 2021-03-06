require 'spec_helper'

describe Changeling::Trackling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
    end

    context "#{model}" do
      describe "callbacks" do
        it "should not create a logling when doing the initial save of a new object" do
          expect(@klass).not_to receive(:create)
          @object.run_callbacks(:create)
        end

        context "after_update" do
          it "should create a logling when updating an object and changes are made" do
            expect(@klass).to receive(:create)
            allow(@object).to receive(:changes).and_return({ :field => 'value' })
          end

          it "should not create a logling when updating an object and changes are empty" do
            expect(@klass).not_to receive(:create)
            allow(@object).to receive(:changes).and_return({})
          end

          it "should not create a logling when updating an object and no changes have been made" do
            expect(@klass).not_to receive(:create)
            allow(@object).to receive(:changes).and_return(nil)
          end

          after(:each) do
            @object.run_callbacks(:update)
          end
        end
      end
    end
  end
end

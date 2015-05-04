require 'spec_helper'
require 'resque'
require 'sidekiq'

describe Changeling::Async::Trackling do
  before(:all) do
    @klass = Changeling::Models::Logling
  end

  async_models.each_pair do |model, args|
    before(:each) do
      @object = model.new(args[:options])
    end

    context "#{model}" do
      describe "without Sidekiq or Resque" do
        before(:each) do
          hide_const("Resque")
          hide_const("Sidekiq")
        end

        it "should raise the AsyncGemRequired exception" do
          expect { @object.async_save_logling }.to raise_error(Changeling::Exceptions::AsyncGemRequired)
        end
      end

      describe "with Sidekiq" do
        before(:each) do
          hide_const("Resque")
        end

        describe "callbacks" do
          before(:each) do
            @logling = @klass.new(@object)
          end

          it "should not create a logling when doing the initial save of a new object" do
            expect(@klass).not_to receive(:new)
            @object.run_callbacks(:create)
          end

          context "after_update" do
            it "should queue a logling to be made when updating an object and changes are made" do
              allow(@object).to receive(:changes).and_return({ :field => 'value' })
              expect(@klass).to receive(:new).and_return(@logling)
              expect(Changeling::Async::SidekiqWorker).to receive(:perform_async).with(@logling.to_indexed_json)
            end

            it "should not queue a logling to be made when updating an object and changes are empty" do
              allow(@object).to receive(:changes).and_return({})
              expect(@klass).not_to receive(:new)
              expect(Changeling::Async::SidekiqWorker).not_to receive(:perform_async)
            end

            it "should not queue a logling to be made when updating an object and no changes have been made" do
              allow(@object).to receive(:changes).and_return(nil)
              expect(@klass).not_to receive(:create)
              expect(Changeling::Async::SidekiqWorker).not_to receive(:perform_async)
            end

            after(:each) do
              @object.run_callbacks(:update)
            end
          end
        end
      end

      describe "with Resque" do
        before(:each) do
          hide_const("Sidekiq")
        end

        describe "callbacks" do
          before(:each) do
            @logling = @klass.new(@object)
          end

          it "should not create a logling when doing the initial save of a new object" do
            expect(@klass).not_to receive(:new)
            @object.run_callbacks(:create)
          end

          context "after_update" do
            it "should queue a logling to be made when updating an object and changes are made" do
              allow(@object).to receive(:changes).and_return({ :field => 'value' })
              expect(@klass).to receive(:new).and_return(@logling)
              expect(Resque).to receive(:enqueue).with(Changeling::Async::ResqueWorker, @logling.to_indexed_json)
            end

            it "should not queue a logling to be made when updating an object and changes are empty" do
              allow(@object).to receive(:changes).and_return({})
              expect(@klass).not_to receive(:new)
              expect(Resque).not_to receive(:enqueue)
            end

            it "should not queue a logling to be made when updating an object and no changes have been made" do
              allow(@object).to receive(:changes).and_return(nil)
              expect(@klass).not_to receive(:create)
              expect(Resque).not_to receive(:enqueue)
            end

            after(:each) do
              @object.run_callbacks(:update)
            end
          end
        end
      end

      describe "with Sidekiq and Resque" do
        describe "callbacks" do
          before(:each) do
            @logling = @klass.new(@object)
          end

          it "should prefer Sidekiq to Resque" do
            allow(@object).to receive(:changes).and_return({ :field => 'value' })
            expect(@klass).to receive(:new).and_return(@logling)
            expect(Changeling::Async::SidekiqWorker).to receive(:perform_async).with(@logling.to_indexed_json)
            expect(Resque).not_to receive(:enqueue)
            @object.run_callbacks(:update)
          end
        end
      end
    end
  end
end

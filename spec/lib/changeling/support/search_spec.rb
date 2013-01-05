require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Support::Search do
  before(:all) do
    @klass = Changeling::Models::Logling
    @search = Changeling::Support::Search
  end

  describe ".find_by" do
    # before(:each) do
    #   @index = @klass.tire.index
    #   @klass.stub_chain(:tire, :index).and_return(@index)
    # end

    # it "should refresh the ElasticSearch index" do
    #   @index.should_receive(:refresh)
    #   @search.find_by({})
    # end
  end
end

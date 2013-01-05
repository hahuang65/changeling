require (File.expand_path('../../../../spec_helper', __FILE__))

describe Changeling::Support::Search do
  before(:all) do
    @klass = Changeling::Models::Logling
    @search = Changeling::Support::Search
  end

  describe ".find_by" do
    before(:each) do
      @index = @klass.tire.index
      @klass.stub_chain(:tire, :index).and_return(@index)

      filters = [
          { :klass => "blog_post" },
          { :oid => "1" }
      ]

      sort = {
        :field => :modified_at,
        :direction => :desc
      }

      @options = { :filters => filters, :sort => sort }

      @results = []

      models.each_pair do |model, args|
        object = model.new(args[:options])
        changes = args[:changes]

        object.stub(:changes).and_return(changes)
        @results << @klass.new(object)
      end

      @klass.stub_chain(:search, :results).and_return(@results)
    end

    it "should return an empty array if options are not a hash" do
      @search.find_by(nil).should == []
    end

    it "should return an empty array if options do not include filters or sort keys" do
      @search.find_by({}).should == []
    end

    it "should refresh the ElasticSearch index" do
      @index.should_receive(:refresh)
      @search.find_by(@options)
    end

    context "results processing" do
      it "should return objects as is if they are Logling objects" do
        @search.find_by(@options).should == @results
      end

      it "should parse them and convert them into Logling objects if they are returned as Tire::Results::Item objects" do
        @tire_object = Tire::Results::Item.new
        @tire_json = "{}"
        @hash = {}

        @results = [@tire_object]
        @klass.stub_chain(:search, :results).and_return(@results)

        @tire_object.should_receive(:to_json).and_return(@tire_json)
        JSON.should_receive(:parse).with(@tire_json).and_return(@hash)
        @klass.should_receive(:new).with(@hash)

        @search.find_by(@options)
      end

      it "should convert them into Logling objects if they are returned as Hash objects" do
        @results = [{}, {}]
        @klass.stub_chain(:search, :results).and_return(@results)

        @results.each { |r| @klass.should_receive(:new).with(r) }
        @search.find_by(@options)
      end
    end
  end
end

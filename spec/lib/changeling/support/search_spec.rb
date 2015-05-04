require 'spec_helper'

describe Changeling::Support::Search do
  before(:all) do
    @klass = Changeling::Models::Logling
    @search = Changeling::Support::Search
  end

  describe ".find_by" do
    before(:each) do
      @index = @klass.tire.index
      allow(@klass).to receive_message_chain(:tire, :index).and_return(@index)

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

        allow(object).to receive(:changes).and_return(changes)
        @results << @klass.new(object)
      end

      allow(@klass).to receive_message_chain(:search, :results).and_return(@results)
    end

    it "should return an empty array if options are not a hash" do
      expect(@search.find_by(nil)).to eq([])
    end

    it "should return an empty array if options do not include filters or sort keys" do
      expect(@search.find_by({})).to eq([])
    end

    it "should refresh the ElasticSearch index" do
      expect(@index).to receive(:refresh)
      @search.find_by(@options)
    end

    context "results processing" do
      it "should return objects as is if they are Logling objects" do
        expect(@search.find_by(@options)).to eq(@results)
      end

      it "should parse them and convert them into Logling objects if they are returned as Tire::Results::Item objects" do
        @tire_object = Tire::Results::Item.new
        @tire_json = "{}"
        @hash = {}

        @results = [@tire_object]
        allow(@klass).to receive_message_chain(:search, :results).and_return(@results)

        expect(@tire_object).to receive(:to_json).and_return(@tire_json)
        expect(JSON).to receive(:parse).with(@tire_json).and_return(@hash)
        expect(@klass).to receive(:new).with(@hash)

        @search.find_by(@options)
      end

      it "should convert them into Logling objects if they are returned as Hash objects" do
        @results = [{}, {}]
        allow(@klass).to receive_message_chain(:search, :results).and_return(@results)

        @results.each { |r| expect(@klass).to receive(:new).with(r) }
        @search.find_by(@options)
      end
    end
  end
end

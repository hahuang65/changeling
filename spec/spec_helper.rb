require(File.expand_path('../../lib/changeling', __FILE__))
require 'mongoid'
require 'database_cleaner'
require 'rails/all'
require 'rspec/rails'
require 'action_controller/railtie' # allows ActionController::Base

# Fixtures
Dir[File.dirname(__FILE__) + "/fixtures/**/*.rb"].each { |file| require file }

# Pre 3.0 Mongoid doesn't have this constant defined...
if defined?(Mongoid::VERSION)
  # Mongoid 3.0.3
  Mongoid.load!(File.dirname(__FILE__) + "/config/mongoid.yml", :test)
else
  # Mongoid 2.4.1
  # Didn't use Mongoid.load! here since 2.4.1 doesn't allow passing in an environment to use.
  Mongoid.database = Mongo::Connection.new('localhost','27017').db('changeling_test')
end

# ActiveRecord setup
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ":memory:" )

ActiveRecord::Migration.verbose = false
ActiveRecord::Schema.define(:version => 1) do
  # See the active_record models under spec/fixtures/models
  create_table :blog_post_active_records do |t|
    t.string  :title
    t.string  :content
    t.boolean :public
  end

  create_table :async_blog_post_active_records do |t|
    t.string  :title
    t.string  :content
    t.boolean :public
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :truncation
    DatabaseCleaner[:mongoid].strategy = :truncation
    Tire::Model::Search.index_prefix "changeling_test"
  end

  config.before(:each) do
    DatabaseCleaner.start
    clear_tire_indexes
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.infer_spec_type_from_file_location!
end

# Inspiration from http://stackoverflow.com/questions/9676089/how-to-test-elasticsearch-in-a-rails-application-rspec
def clear_tire_indexes
  [Changeling::Models::Logling].each do |model|
    # Make sure that the current model is using Tire
    if model.respond_to?(:tire)
      # Delete the index for the model.
      model.tire.index.delete

      # Reload the model's index so that it can be used again.
      model.tire.create_elasticsearch_index
    end
  end
end

def common_conditions
  hash = {
    :options => {
      :title => "Changeling",
      :content => "Something about Changeling",
      :public => false
    },
    :changes => {
      "public" => [false, true],
      "content" => ["Something about Changeling", "Content about Changeling"]
    }
  }
end

def models
  @models = {
    BlogPost => common_conditions,
    BlogPostNoTimestamp => common_conditions,
    BlogPostActiveRecord => common_conditions
  }
end

def async_models
  @models = {
    AsyncBlogPost => common_conditions,
    AsyncBlogPostNoTimestamp => common_conditions,
    AsyncBlogPostActiveRecord => common_conditions
  }
end

require(File.expand_path('../../lib/changeling', __FILE__))
require 'mongoid'
require 'redis'
require 'database_cleaner'

# Fixtures
require(File.expand_path('../fixtures/models/blog_post', __FILE__))

Mongoid.database = Mongo::Connection.new('localhost','27017').db('changeling_test')

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:suite) do
    DatabaseCleaner[:mongoid].strategy = :truncation
    $redis = Redis.new(:db => 1)
  end

  config.before(:each) do
    $redis.flushdb
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

def models
  @models = {
    BlogPost => {
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
  }
end

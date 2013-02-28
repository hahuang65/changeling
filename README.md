# Changeling [![Build Status][travis-image]][travis-link] [![Gem Version](https://badge.fury.io/rb/changeling.png)](http://badge.fury.io/rb/changeling)

[travis-image]: https://secure.travis-ci.org/hahuang65/Changeling.png?branch=master
[travis-link]: http://travis-ci.org/hahuang65/Changeling
[travis-home]: http://travis-ci.org/
[brew-home]: http://mxcl.github.com/homebrew/
[elasticsearch-home]: http://www.elasticsearch.org
[sidekiq-home]: https://github.com/mperham/sidekiq
[resque-home]: https://github.com/defunkt/resque

A flexible and lightweight object change tracking system.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'changeling'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install changeling
```

## Requirements

* [ElasticSearch][elasticsearch-home] (Tested on 0.19.9 with JVM 20.10-b01-428)
  * Install via [Homebrew][brew-home]

```sh
$ brew install elasticsearch
```

## Usage
### Models
Include the Trackling module for any class you want to keep track of:

```ruby
class Post
  include Changeling::Trackling

  # Model logic here...
end
```

### Controllers
If you are using a Rails app, and have the notion of a "user"", you may want to track of which user made which changes.
Unfortunately models don't understand the concept of the currently signed in user. We'll have to leverage the controller to tack on this information.

```ruby
# Doesn't have to be ApplicationController, perhaps you only want it in controllers for certain resources.
class ApplicationController < ActionController::Base
    include Changeling::Blameling

    # Changeling assumes your user is current_user, but if not, override the changeling_blame_user method like so:
    def changeling_blame_user
        current_account
    end

    # Controller logic here...
end
```

### Asynchronous Tracking
Sometimes in high production load, you don't want another gem clogging up your resource pipeline, slowing down performance and potentially causing downtime.
Changeling has built-in Asynchronous support so you don't have to go and write your own callbacks and queues!
Changeling is compatible with [Sidekiq][sidekiq-home] and [Resque][resque-home].
When your object is saved, a job is placed in the 'changeling' queue.

```ruby
class Post
  # include Changeling::Trackling
  include Changeling::Async::Trackling

  # Model logic here...
end
```

### Accessing Changeling's history
If you wish to see what has been logged, include the Probeling module:

```ruby
class Post
  include Changeling::Trackling
  include Changeling::Probeling

  # Model logic here...
end
```

With Probeling, you can check out the changes that have been made! They're stored in the order that the changes are made.
You can access the up to the last 10 changes simply by calling

```ruby
# Alias for this method: @post.history
@post.loglings
```

You can access a different number of records by passing in a number to the .loglings method:

```ruby
# Will automatically handle if there are less than the number of histories requested.
@post.loglings(50)
```

Access an object's last 10 changes where a specific field was changed:

```ruby
# Alias for this method: @post.history_for_field(field)
@post.loglings_for_field(:title)
# Or if you prefer stringified fields:
@post.loglings_for_field('title')

# You can also pass in a number to get more results
@post.loglings_for_field(:title, 50)
```

### Logling Properties (history objects):

```ruby
log = @post.loglings.first

log.klass # class of the object that the Logling is tracking.
=> Post

log.oid # the ID of the object that the Logling is tracking.
# Note: integer type IDs will be integers. Non-integer types (such as Mongo's IDs) will be represented as a string.
=> 1

log.before # what the before state of the object was.
=> {"title" => "Old Title"}

log.after # what the after state of the object is.
=> {"title" => "New Title"}

log.modified_by # ID of the user who made the changes to the object
# Note: this could be nil if the Blameling module was not set up in you controller, or if changes were made from a place without a user object, such as the Rails console.
# Note: integer type IDs will be integers. Non-integer types (such as Mongo's IDs) will be represented as a string.
=> 33

log.modifications # what changes were made to the object that this Logling recorded. Basically a roll up of the .before and .after methods.
=> {"title" => ["Old Title", "New Title"]}

log.modified_at # what time these changes were made.
=> Sat, 08 Sep 2012 10:21:46 UTC +00:00

log.as_json # JSON representation of the changes.
=> {:class => Post, :oid => 1, :modified_by => 33, :modifications=> { "title" => ["Old Title", "New Title"] }, :modified_at => Sat, 08 Sep 2012 10:21:46 UTC +00:00}
```

## Testing

This library is tested using [Travis][travis-home], where it is tested
against the following interpreters (with corresponding ORM/ODMs) and datastores:

* MRI 1.9.2 (Mongoid 2.4.1, ActiveRecord 3.1.3)
* MRI 1.9.3 (Mongoid 3.0.3, ActiveRecord 3.2.7)
* ElasticSearch (Tested on 0.19.9 with JVM 20.10-b01-428)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

* Restore state from a Logling
* Performance testing against large data loads.
* Sinatra app to monitor changes as they happen in real-time.
* Analytics for changes.
* Much more...

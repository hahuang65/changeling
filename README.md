# Changeling [![Build Status][travis-image]][travis-link]

[travis-image]: https://secure.travis-ci.org/hahuang65/Changeling.png?branch=master
[travis-link]: http://travis-ci.org/hahuang65/Changeling
[travis-home]: http://travis-ci.org/
[brew-home]: http://mxcl.github.com/homebrew/
[elasticsearch-home]: http://www.elasticsearch.org

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

Include the Trackling module for any class you want to keep track of:

```ruby
class Post
  include Changeling::Trackling

  # Model logic here...
end
```

That's it! Including the module will silently keep track of any changes made to objects of this class.
For example:

```ruby
@post = Post.first
@post.title
=> 'Old Title'
@post.title = 'New Title'
@post.save
```

This code will save a history that represents that the title for this post has been changed.

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
@post.history
```

You can access a different number of records by passing in a number to the .history method:

```ruby
# Will automatically handle if there are less than the number of histories requested.
@post.history(50)
```

Access all of an objects history:

```ruby
@post.all_history
```

Properties of Loglings (history objects):

```ruby
log = @post.history.first

log.klass # class of the object that the Logling is tracking.
=> "posts"

log.oid # the ID of the object that the Logling is tracking.
=> "1"

log.before # what the before state of the object was.
=> {"title" => "Old Title"}

log.after # what the after state of the object is.
=> {"title" => "New Title"}

log.modifications # what changes were made to the object that this Logling recorded. Basically a roll up of the .before and .after methods.
=> {"title" => ["Old Title", "New Title"]}

log.modified_at # what time these changes were made.
=> Sat, 08 Sep 2012 10:21:46 UTC +00:00

log.as_json # JSON representation of the changes.
=> {:modifications=>{"title" => ["Old Title", "New Title"], :modified_at => Sat, 08 Sep 2012 10:21:46 UTC +00:00}
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
* Filter Loglings by which fields have changed.
* Performance testing against large data loads.
* Sinatra app to monitor changes as they happen in real-time.
* Analytics for changes.
* Much more...

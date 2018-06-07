# About

[![Gem version][GV img]][Gem version]
[![Build status][BS img]][Build status]
[![Coverage status][CS img]][Coverage status]
[![CodeClimate status][CC img]][CodeClimate status]
[![YARD documentation][YD img]][YARD documentation]

How much abstraction is too much?

On one hand <abbr title="Inversion of control">IoC</abbr> is probably a too heavy canon for a dynamic language like Ruby, instantiating external dependencies in `#initalize` doesn't sound like a good idea either.

If I have to replace a dependency, I want to know what interface it has to provide.

That is what methods is my project actually using, so not the same as `class MyCollection implements ListInterface`.

# Example

```ruby
require 'import'

Interfacer = import('interfacer').Interfacer

class Post
  extend Interfacer

  attribute(:time_class, '.now', '#to_s') { Time }

  def publish!
    "~ Post #{self.inspect} has been published at #{self.time_class.now} (using #{self.time_class})."
  end
end

puts "~ With the default time_class."
post = Post.new
puts post.publish!

puts "\n~ With overriden time_class."
require 'date'

post = Post.new
post.time_class = DateTime
puts post.publish!
```

To me, this is what I consider to be the golden middle way. There's nearly no extra code, no factory method etc, but I can replace the time class any time I want.

Why?

```ruby
class TimeMock
  class << self
    alias_method :now, :new
  end

  def to_s
    'Monday evening'
  end
end

describe Post do
  before(:each) do
    subject.time_class = TimeMock
  end

  it "prints out when a post was published" do
    expect(post.publish!).to match(/has been published at Monday evening/)
  end
end
```

You can say that you could just stub `Time.now` and you're right, but I'm not a huge fan of that approach. I like clear dependencies, actual objects and (on a slightly different subject, but still vaguely related) I think tests should test public APIs and not order in which things are executed (when used mocks), because everything breaks when you do internal refactoring.

But whatever, let's have an another example.

```ruby
settings = import('settings')

class Post
  attribute :json_encoder, '.generate' { settings.json_encoder }
end
```

Now when you decide to switch to say `oj`, all you have to do is this:

```ruby
# settings.rb

require 'oj'

export json_encoder: Oj
```

[Gem version]: https://rubygems.org/gems/interfacer
[Build status]: https://travis-ci.org/botanicus/interfacer
[Coverage status]: https://coveralls.io/github/botanicus/interfacer
[CodeClimate status]: https://codeclimate.com/github/botanicus/interfacer/maintainability
[YARD documentation]: http://www.rubydoc.info/github/botanicus/interfacer/master

[GV img]: https://badge.fury.io/rb/interfacer.svg
[BS img]: https://travis-ci.org/botanicus/interfacer.svg?branch=master
[CS img]: https://img.shields.io/coveralls/botanicus/interfacer.svg
[CC img]: https://api.codeclimate.com/v1/badges/a99a88d28ad37a79dbf6/maintainability
[YD img]: http://img.shields.io/badge/yard-docs-blue.svg

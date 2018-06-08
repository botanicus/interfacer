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
JsonEncoder = import('registry').json_encoder

class Post
  attribute :json_encoder, '.generate' { JsonEncoder }
end
```

Now when you decide to switch to say `oj`, all you have to do is this:

```ruby
# registry.rb

# Lazy loading, the result is cached.
export(:json_encoder) do
  import('adapters/oj')
end
```

So instead of having bunch of `require 'json'` calls, `JSON` module referenced in many places and `#to_json` calls used on monkey-patched core classes (ay!), we have one `require` statement, one statement of registering the encoder and then every class specifying what does it need from the encoder.

The last bit is very powerful. Instead of declaring an interface (_from the top down_) and implementing all the methods interface requires, we basically define something like interface for our project (_from the bottom up_).

OK, JSON encoders all looks the same. But what about say HTTP requests?

```ruby
# http_adapter.rb

require 'net/http'

def exports.get(url)
  # TODO: Implement using net/http.
end
```

```ruby
# registry.rb

export(:http_adapter) do
  import('net_http_adapter')
end

export log_path: '/var/logs/post.log'

export(:logger) do
  require 'logger'
  Logger.new(exports.log_path)
end
```

```ruby
http_adapter, logger = import('registry').grap(:http_adapter, :logger)

class Post
  attribute :http_adapter, '.get' { http_adapter }
  attribute :logger, :debug, :info, :error { logger }
end
```

HTTP libraries have bunch of methods. But in this case, all we care about is to have a `#get` method accepting URL and returning a stream.

### But ... what about need-based coding (TODO: find how it's really called).

Specifying the dependencies and putting in a trivial adapter will take you few seconds at the beginning on the project. And fair enough, maybe your startup goes bancrupt in 5 months and you won't ever have to deal with switching libraries.

But if not, and the project grows with implicit dependencies, good luck switching anything. The 2 minutes you saved on the beginning will cost you hours, if not days plus a lot of pulled out hair all over.

And this happens. During my early years Hpricot was the library one would use to parse HTML.So say I'd write a project using the library. These days the new kids has never even heard of Hpricot and after _why went missing, there's no chance of new version or even anyone knowing much about it anymore.

The solution? Switching to Nokogiri of course.

Writing adapters will force you to be simple. That's good.

And yes, there are libraries that you won't be able to mock out this way. If they'd be gone, you'd have to make some changes. For instance [scheduled-format](https://github.com/botanicus/scheduled-format) relies on parslet. Would parslet be gone, I'd have to change or replace the `Parser` and `Transformer` class and the `.parse` method.

It's not about doing the theoretically right thing, it's about doing what's best for productivity and maintanability. And yes, there is a line. But at least you'll make a conscious decision, what's a pluggable dependency and what's the one or few libraries that the project just can't do without.

Replacing JSON everywhere except of file n say because of a bug (or RAILS_ENV n? better debuggin etc?)

And let's say you use some libraries that all use JSON. Wouldn't it be nice if you could switch them to use Oj instead?

```ruby
import('my_lib')

my_lib.registry.json_adapter = Oj
```

```ruby
# task.rb
export Task: (Task = Class.new)

# task_list.rb
Task = import('registry').Task

export TaskList: (TaskList = Class.new {
  attribute :task_class, '#name' { Task }
})

# registry.rb
export(:Task) do
  import('mylib/task')
end
```

# TODO

- Read up: dependency inversion vs. dependency injection, IoC, IoC container.
- Note that there should be no require 'component', only require 'registry'. Requires only to hard-wired stuff like parslet.
- Rename `attribute` to `require_component` or `inject`?
- https://github.com/alexeypetrushin/micon/blob/master/docs/ultima2.rb and https://github.com/alexeypetrushin/rubylang/blob/master/draft/you-underestimate-the-power-of-ioc.md
- Add interface check to include/extend (resp. define include_component module, interface: ['#to_s']. Either way always include location_service.something.
- https://phpfashion.com/co-je-dependency-injection
- How about autodiscovery for the current library? That is not with the outside world.
- http://dry-rb.org/gems/dry-container/ and http://dry-rb.org/gems/dry-auto_inject/ resp. https://github.com/dry-rb
- https://gist.github.com/blairanderson/8072d951a480a590f0bd
- https://www.martinfowler.com/articles/injection.html
- https://stackoverflow.com/questions/871405/why-do-i-need-an-ioc-container-as-opposed-to-straightforward-di-code
- Explanation http://ruby-for-beginners.rubymonstas.org/blocks/ioc.html

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

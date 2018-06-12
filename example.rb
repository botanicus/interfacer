#!/usr/bin/env ruby -Ilib
# frozen_string_literal: true

require 'import'

Interfacer = import('interfacer').Interfacer

class Post
  extend Interfacer

  attribute(:time_class, '.now', '#to_s') { Time }

  def publish!
    puts "~ Post #{self.inspect} has been published at #{self.time_class.now} (using #{self.time_class})."
  end
end

puts "~ With the default time_class."
post = Post.new
post.publish!

puts "\n~ With overriden time_class."
require 'date'

post = Post.new
post.time_class = DateTime
post.publish!

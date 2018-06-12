#!/usr/bin/env ruby -rbundler/setup
# frozen_string_literal: true

require 'import'

# Here we are on the top-level, so we don't want to mess it up with constants.
json_adapter, post_repository, interfacer = import('registry').
  grab(:json_adapter, :post_repository, :interfacer)

# Aaaand since we're using local variables, we need to use a closure for a class definition.
MyClass = Class.new {
  extend interfacer

  attribute(:json_adapter, :parse, :generate) { json_adapter }
  attribute(:post_repository, :retrieve) { post_repository }

  def deserialise
    json_adapter.parse(post_repository.retrieve)
  end

  def serialise(objects)
    json_adapter.generate(objects)
  end
}

# Main.
puts "~ Using #{json_adapter.name}."
object = MyClass.new
posts = object.deserialise
puts "Data: #{posts.inspect}"
puts "JSON: #{object.serialise(posts)}"

json_adapter = import('adapters/oj')
puts "\n~ Using #{json_adapter.name}."
object = MyClass.new
posts = object.deserialise
puts "Data: #{posts.inspect}"
puts "JSON: #{object.serialise(posts)}"

# frozen_string_literal: true

require 'import'

Interfacer, InterfaceRequirementsNotMetError = import('interfacer').
  grab(:Interfacer, :InterfaceRequirementsNotMetError)

class Post
  extend Interfacer

  attribute(:time_class, '.now', '#to_s') { Time }
end

describe "assigning a class" do
  context "with an incomplete interface" do
    it "throws an error" do
      expect { Post.new.time_class = Class.new }.to raise_error(InterfaceRequirementsNotMetError)
    end
  end

  # TODO: contexts for .method vs #method.

  context "with a complete interface" do
    it "succeeds" do
      expect { Post.new.time_class = Time }.not_to raise_error
    end
  end
end

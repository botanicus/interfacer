# frozen_string_literal: true

require 'oj'

def exports.parse(text)
  Oj.load(text)
end

def exports.generate(object)
  Oj.dump(object)
end

export name: 'OjAdapter'

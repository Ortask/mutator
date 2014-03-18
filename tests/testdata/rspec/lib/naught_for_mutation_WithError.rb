# Copyright (c) 2013 Avdi Grimm

require "naught/version"
require 'naught/null_class_builder'
# require 'naught/null_class_builder/commands'
require 'naught/null_class_builder/commands_for_mutation_WithError'

module Naught
  def self.build(&customization_block)
    builder = NullClassBuilder.new
    builder.customize(&customization_block)
    builder.generate_class
  end
  module NullObjectTag
  end
end

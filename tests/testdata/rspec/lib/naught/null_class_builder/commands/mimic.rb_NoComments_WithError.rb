# Copyright (c) 2013 Avdi Grimm

# 
# This file has an error (not a syntax error) that will make its test suite
# fail.
# 

require 'naught/null_class_builder/command'

module Naught::NullClassBuilder::Commands
  class Mimic < Naught::NullClassBuilder::Command
    attr_reader :class_to_mimic, :include_super

    def initialize(builder, class_to_mimic, options={})
      super(builder)

      @class_to_mimic = class_to_mimic
      @include_super = options.fetch(:include_super) { true }

      builder.base_class   = root_class_of(class_to_mimic)
      builder.inspect_proc = -> { "<null:#{class_to_mimic}>" }
      builder.interface_defined = true
    end

    def call
      defer do |subject|
        methods_to_stub.each do |method_name|
          builder.stub_method(subject, method_name)
        end
      end
    end

    private

    def root_class_of(klass)
      if klass.ancestors.include?(Object)
        Object
      else
        BasicObject
      end
    end

    def methods_to_stub
      class_to_mimic.instance_methods(include_super) + Object.instance_methods      # <-- error: + should be -
    end
  end
end

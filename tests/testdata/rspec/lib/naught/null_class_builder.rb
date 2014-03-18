# Copyright (c) 2013 Avdi Grimm

require 'naught/null_class_builder/conversions_module'

module Naught
  class NullClassBuilder
    # make sure this module exists
    module Commands
    end

    attr_accessor :base_class, :inspect_proc, :interface_defined

    def initialize
      @interface_defined = false
      @base_class        = BasicObject
      @inspect_proc      = ->{ "<null>" }
      @stub_strategy     = :stub_method_returning_nil
      define_basic_methods
    end

    def interface_defined?
      @interface_defined
    end

    def customize(&customization_block)
      return unless customization_block
      customization_module.module_exec(self, &customization_block)
    end

    def customization_module
      @customization_module ||= Module.new
    end

    def null_equivalents
      @null_equivalents ||= [nil]
    end

    def generate_conversions_module(null_class)
      ConversionsModule.new(null_class, null_equivalents)
    end

    def generate_class
      respond_to_any_message unless interface_defined?
      generation_mod    = Module.new
      customization_mod = customization_module # get a local binding
      builder           = self

      apply_operations(operations, generation_mod)

      null_class = Class.new(@base_class) do
        const_set :GeneratedMethods, generation_mod
        const_set :Customizations, customization_mod
        const_set :Conversions, builder.generate_conversions_module(self)

        include NullObjectTag
        include generation_mod
        include customization_mod
      end

      apply_operations(class_operations, null_class)

      null_class
    end

    def method_missing(method_name, *args, &block)
      command_name = command_name_for_method(method_name)
      if Commands.const_defined?(command_name)
        command_class = Commands.const_get(command_name)
        command_class.new(self, *args, &block).call
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private=false)
      command_name = command_name_for_method(method_name)
      Commands.const_defined?(command_name) || super
    rescue NameError
      super
    end

    ############################################################################
    # Builder API
    #
    # See also the contents of lib/naught/null_class_builder/commands
    ############################################################################

    def black_hole
      @stub_strategy = :stub_method_returning_self
    end

    def respond_to_any_message
      defer(prepend: true) do |subject|
        subject.module_eval do
          def respond_to?(*)
            true
          end
        end
        stub_method(subject, :method_missing)
      end
      @interface_defined = true
    end

    def defer(options={}, &deferred_operation)
      list = options[:class] ? class_operations : operations
      if options[:prepend]
        list.unshift(deferred_operation)
      else
        list << deferred_operation
      end
    end

    def stub_method(subject, name)
      send(@stub_strategy, subject, name)
    end

    private

    def define_basic_methods
      define_basic_instance_methods
      define_basic_class_methods
    end

    def apply_operations(operations, module_or_class)
      operations.each do |operation|
        operation.call(module_or_class)
      end
    end

    def define_basic_instance_methods
      defer do |subject|
        subject.module_exec(@inspect_proc) do |inspect_proc|
          define_method(:inspect, &inspect_proc)
          def initialize(*)
          end
        end
      end
    end

    def define_basic_class_methods
      defer(class: true) do |subject|
        subject.module_eval do
          class << self
            alias get new
          end
          klass = self
          define_method(:class) { klass }
        end
      end
    end

    def class_operations
      @class_operations ||= []
    end

    def operations
      @operations ||= []
    end

    def stub_method_returning_nil(subject, name)
      subject.module_eval do
        define_method(name) {|*| nil }
      end
    end

    def stub_method_returning_self(subject, name)
      subject.module_eval do
        define_method(name) {|*| self }
      end
    end

    def command_name_for_method(method_name)
      method_name.to_s.gsub(/(?:^|_)([a-z])/) { $1.upcase }
    end
  end
end

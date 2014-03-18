# Copyright (c) 2013 Avdi Grimm

module Naught
  class NullClassBuilder
    class Command
      attr_reader :builder

      def initialize(builder)
        @builder = builder
      end

      def call
        raise NotImplementedError,
              "Method #call should be overriden in child classes"
      end

      def defer(options={}, &block)
        @builder.defer(options, &block)
      end
    end
  end
end

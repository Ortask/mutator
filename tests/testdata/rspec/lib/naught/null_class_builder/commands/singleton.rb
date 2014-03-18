# Copyright (c) 2013 Avdi Grimm

require 'naught/null_class_builder/command'

module Naught::NullClassBuilder::Commands
  class Singleton < Naught::NullClassBuilder::Command
    def call
      defer(class: true) do |subject|
        require 'singleton'
        subject.module_eval do
          include ::Singleton

          def self.get(*)
            instance
          end

          %w(dup clone).each do |method_name|
            define_method method_name do
              self
            end
          end
        end
      end
    end
  end
end

# Copyright (c) 2013 Avdi Grimm

module Naught::NullClassBuilder::Commands
  class Impersonate < Naught::NullClassBuilder::Commands::Mimic
    def initialize(builder, class_to_impersonate, options={})
      super

      builder.base_class   = class_to_impersonate
    end
  end
end

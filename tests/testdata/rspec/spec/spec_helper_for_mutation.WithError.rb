# Copyright (c) 2013 Avdi Grimm

GEM_ROOT = File.expand_path("../../", __FILE__)
$:.unshift File.join(GEM_ROOT, "lib")

require 'naught_for_mutation_WithError'
Dir[File.join(GEM_ROOT, "spec", "support", "**/*.rb")].each { |f| require f }

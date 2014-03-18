# Copyright (c) 2013 Avdi Grimm

require './spec_helper_for_mutation'
require 'stringio'

describe 'pebble null object' do
  class Caller
    def call_method(thing)
      thing.info
    end

    def call_method_inside_block(thing)
      2.times.each { thing.info }
    end

    def call_method_inside_nested_block(thing)
      2.times.each { 2.times.each { thing.info } }
    end
  end

  subject(:null) { null_class.new }
  let(:null_class) {
    output = test_output # getting local binding
    Naught.build do |b|
      b.pebble output
    end
  }

  let(:test_output) { StringIO.new }

  it 'prints the name of the method called' do
    expect(test_output).to receive(:puts).with(/^info\(\)/)
    null.info
  end

  it 'prints the arguments received' do
    expect(test_output).to receive(:puts).with(/^info\(\'foo\', 5, \:sym\)/)
    null.info("foo", 5, :sym)
  end

  it 'prints the name of the caller' do
    expect(test_output).to receive(:puts).with(/from call_method$/)
    Caller.new.call_method(null)
  end

  it 'returns self' do
    expect(null.info).to be(null)
  end

  context "when is called from a block" do
    it "prints the indication of a block" do
      expect(test_output).to receive(:puts).twice.
        with(/from block/)
      Caller.new.call_method_inside_block(null)
    end

    it "prints the name of the method that has the block" do
      expect(test_output).to receive(:puts).twice.
        with(/in call_method_inside_block$/)
      Caller.new.call_method_inside_block(null)
    end
  end

  context "when is called from many levels blocks" do
    it "prints the indication of blocks and its levels" do
      expect(test_output).to receive(:puts).exactly(4).times.
        with(/from block \(2 levels\)/)
      Caller.new.call_method_inside_nested_block(null)
    end

    it "prints the name of the method that has the block" do
      expect(test_output).to receive(:puts).exactly(4).times.
        with(/in call_method_inside_nested_block$/)
      Caller.new.call_method_inside_nested_block(null)
    end
  end
end

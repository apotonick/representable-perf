#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'representable/json'
require 'representable/decorator'
require 'ruby-prof'
require 'benchmark'
require 'oj'

class Foo
  attr_accessor :value, :bar
end

class Bar
  attr_accessor :value
end

module Representables

  class BarRepresentation < Representable::Decorator
    include Representable::JSON
    # include Representable::Cached
    property :value
  end

  class FooRepresentation < Representable::Decorator
    include Representable::JSON
    # include Representable::Cached
    property :value
    property :bar, :decorator => BarRepresentation
  end

  class FoosRepresentation < Representable::Decorator
    include Representable::JSON
    # feature Representable::Cached
    property :count
    # collection :foos, :class => Foo, :decorator => FooRepresentation
    collection :foos do
      property :value

      property :bar do
        property :value
      end
    end
  end

end


TESTMETHODS = ['bench', 'profile']

testmethod = 'bench'
unless ARGV.empty?
  if TESTMETHODS.include? ARGV[0]
    testmethod = ARGV[0]
  else
    puts "Unknown testmethod. Supply one of #{TESTMETHODS.join(',')}"
    exit
  end
end

def bar_to_hash(bar)
  {'value' => bar.value}
end

def foo_to_hash(foo)
  {'value' => foo.value, 'bar' => bar_to_hash(foo.bar)}
end

def foos_to_array(foos)
  a = []
  foos.each do |foo|
    a << foo_to_hash(foo)
  end
  a
end

def foos_to_json(foos)
  Oj.dump({'count' => foos.count, 'foos' => foos_to_array(foos)})
end

FoosStruct = Struct.new(:count, :foos)

foos = []

10000.times do |i|
  bar = Bar.new
  bar.value = i
  foo =  Foo.new
  foo.value = i
  foo.bar = bar
  foos << foo
end

# if testmethod == 'bench'
#   Benchmark.bm do |x|
#   x.report("roar") {
#     fs = FoosStruct.new(foos.count, foos)
#     json = Roars::FoosRepresentation.new(fs).to_json
#   }
#   x.report("representable") {
#     fs = FoosStruct.new(foos.count, foos)
#     json = Representables::FoosRepresentation.new(fs).to_json
#   }
#   x.report("by hand") {
#     foos_to_json(foos)
#   }
#   end
# else
  # RubyProf.start
  #   fs = FoosStruct.new(foos.count, foos)
  #   json = Roars::FoosRepresentation.new(fs).to_json
  # res = RubyProf.stop
  # printer = RubyProf::FlatPrinter.new(res)
  # puts "roar:"
  # printer.print(STDOUT)
  RubyProf.start
    fs = FoosStruct.new(foos.count, foos)
    json = Representables::FoosRepresentation.new(fs).to_json
  res = RubyProf.stop
  printer = RubyProf::FlatPrinter.new(res)
  puts "representable:"
  printer.print(STDOUT)
  # RubyProf.start
  #   foos_to_json(foos)
  # res = RubyProf.stop
  # printer = RubyProf::FlatPrinter.new(res)
  # puts "by hand:"
  # printer.print(STDOUT)
# end

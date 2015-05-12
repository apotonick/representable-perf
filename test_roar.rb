#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'
require 'roar/json'
require 'roar/decorator'
require 'ruby-prof'

class Foo
  attr_accessor :value, :bar
end

class Bar
  attr_accessor :value
end

class BarRepresentation < Roar::Decorator
  include Roar::JSON
  property :value
end

class FooRepresentation < Roar::Decorator
  include Roar::JSON
  property :value
  property :bar, :decorator => BarRepresentation
end

class FoosRepresentation < Roar::Decorator
  include Roar::JSON
  property :count
  collection :foos, :class => Foo, :decorator => FooRepresentation
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

fs = FoosStruct.new(foos.count, foos)
#RubyProf.start
json = FoosRepresentation.new(fs).to_json
#res = RubyProf.stop
#printer = RubyProf::FlatPrinter.new(res)
#printer.print(STDOUT)

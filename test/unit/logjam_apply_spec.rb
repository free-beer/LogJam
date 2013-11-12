#! /usr/bin/env ruby
# Copyright (c) 2013, Peter Wood.
# See the license.txt for details of the licensing of the code in this file.

require 'minitest/autorun'
require 'minitest/spec'
require 'logjam'

class ApplyTestClass
   LogJam.apply(self, "ApplyTestClass")
end

describe "LogJam.apply method" do
   it "possesses a class level log method" do
      ApplyTestClass.respond_to?(:log).must_equal(true)
   end

   it "possesses an instance level log method" do
      instance = ApplyTestClass.new
      instance.respond_to?(:log).must_equal(true)
   end
end
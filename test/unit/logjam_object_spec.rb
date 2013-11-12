#! /usr/bin/env ruby
# Copyright (c) 2013, Peter Wood.
# See the license.txt for details of the licensing of the code in this file.

require 'minitest/autorun'
require 'minitest/spec'
require 'logjam'

describe Object do
   it "possesses a class level log method" do
      Object.respond_to?(:log).must_equal(true)
   end

   it "possesses an instance level log method" do
      "".respond_to?(:log).must_equal(true)
   end
end
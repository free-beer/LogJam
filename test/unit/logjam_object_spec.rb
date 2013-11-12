#! /usr/bin/env ruby
# Copyright (c) 2013, Peter Wood.
# See the license.txt for details of the licensing of the code in this file.

require 'minitest/autorun'
require 'minitest/spec'
require 'logger'
require 'logjam'

describe Object do
   it "possesses a class level log method" do
      Object.respond_to?(:log).must_equal(true)
      Object.log.class.must_equal(LogJam::LogJamLogger)
   end

   it "possesses an instance level log method" do
      "".respond_to?(:log).must_equal(true)
      "".log.class.must_equal(LogJam::LogJamLogger)
   end

   it "possesses a class level log= method" do
      Object.respond_to?(:log=).must_equal(true)
   end

   it "reassigns the logger when asked to do so" do
      logger = Logger.new(STDERR)
      Object.log = logger
      Object.log.logger.must_equal(logger)
   end
end
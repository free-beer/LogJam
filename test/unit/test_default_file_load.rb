#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

gem 'test-unit', ">= 2.0.0"
require 'json'
require 'logjam'
require 'pp'
require 'test/unit'
require 'yaml'

class TestLogJamFileLoad < Test::Unit::TestCase
   class << self
      include StartUpAndShutdown
   end
   include SuiteUtilities

   def setup
      clear_configurations
   end

   def test_configure_with_yaml_configuration
      write_yaml_configuration
      LogJam.configure(nil)
      
      assert_equal(3, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("silent"))
      assert_equal(true, LogJam.names.include?("verbose"))
      assert_equal(true, LogJam.names.include?("class01"))
      assert_not_equal(LogJam.get_logger("silent"), LogJam.get_logger("verbose"))
      assert_equal(LogJam.get_logger, LogJam.get_logger("silent"))
   end

   def test_configure_with_json_configuration
      write_json_configuration
      LogJam.configure(nil)
      
      assert_equal(3, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("silent"))
      assert_equal(true, LogJam.names.include?("verbose"))
      assert_equal(true, LogJam.names.include?("class01"))
      assert_not_equal(LogJam.get_logger("silent"), LogJam.get_logger("verbose"))
      assert_equal(LogJam.get_logger, LogJam.get_logger("silent"))
   end
end
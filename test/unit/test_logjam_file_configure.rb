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

class TestLogJamFileConfigure < Test::Unit::TestCase
   class << self
      include StartUpAndShutdown
   end
   include SuiteUtilities

   def setup
      clear_configurations 
   end
   
   def teardown
   end

   def test_yaml_configure
      write_yaml_configuration
      LogJam.configure("./config/logging.yml")

      assert_equal(false, LogJam.names.empty?)
      assert_equal(3, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("silent"))
      assert_equal(true, LogJam.names.include?("verbose"))
      assert_equal(true, LogJam.names.include?("class01"))

      assert_not_equal(LogJam.get_logger, LogJam.get_logger("verbose"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("class01"))
      assert_equal(LogJam.get_logger, LogJam.get_logger("silent"))
      assert_equal(LogJam.get_logger("verbose"), LogJam.get_logger("class01"))
   end

   def test_json_configure
      write_json_configuration
      LogJam.configure("./config/logging.json")

      assert_equal(false, LogJam.names.empty?)
      assert_equal(3, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("silent"))
      assert_equal(true, LogJam.names.include?("verbose"))
      assert_equal(true, LogJam.names.include?("class01"))

      assert_not_equal(LogJam.get_logger, LogJam.get_logger("verbose"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("class01"))
      assert_equal(LogJam.get_logger, LogJam.get_logger("silent"))
      assert_equal(LogJam.get_logger("verbose"), LogJam.get_logger("class01"))
   end
end
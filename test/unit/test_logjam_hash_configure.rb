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

class TestLogJamHashConfigure < Test::Unit::TestCase
   class << self
      include StartUpAndShutdown
   end

   def setup
      LogJam.configure({})
   end
   
   def teardown
   end
   
   def test_basic_configure
      assert_equal([], LogJam.names)
      assert_not_nil(LogJam.get_logger)

      configuration = {:loggers => [{:name => "logger01",
                                     :file => "STDOUT"},
                                    {:name => "logger02",
                                     :file => "STDOUT"}]}
      LogJam.configure(configuration)

      assert_equal(false, LogJam.names.empty?)
      assert_equal(2, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("logger01"))
      assert_equal(true, LogJam.names.include?("logger02"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("logger01"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("logger01"))
      assert_not_equal(LogJam.get_logger("logger01"), LogJam.get_logger("logger02"))
   end
   
   def test_aliases_configure
      configuration = {:loggers => [{:name => "logger01",
                                     :file => "STDOUT"},
                                    {:name => "logger02",
                                     :file => "STDOUT"}],
                       :aliases => {"other01" => "logger02",
                                    "other02" => "logger01"}}
      LogJam.configure(configuration)
      assert_equal(false, LogJam.names.empty?)
      assert_equal(4, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("logger01"))
      assert_equal(true, LogJam.names.include?("logger02"))
      assert_equal(true, LogJam.names.include?("other01"))
      assert_equal(true, LogJam.names.include?("other02"))
      
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("logger01"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("logger01"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("other01"))
      assert_not_equal(LogJam.get_logger, LogJam.get_logger("other02"))
      assert_not_equal(LogJam.get_logger("logger01"), LogJam.get_logger("logger02"))
      assert_not_equal(LogJam.get_logger("other01"), LogJam.get_logger("logger01"))
      assert_not_equal(LogJam.get_logger("other02"), LogJam.get_logger("logger02"))
      assert_equal(LogJam.get_logger("other02"), LogJam.get_logger("logger01"))
      assert_equal(LogJam.get_logger("other01"), LogJam.get_logger("logger02"))
   end
end
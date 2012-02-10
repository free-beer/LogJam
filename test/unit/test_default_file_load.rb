#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'json'
require 'logjam'
require 'pp'
require 'test/unit'
require 'yaml'

class TestLogJamConfigure < Test::Unit::TestCase
   def setup
      if File.exists?("logs")
         # Delete all existing log files.
         Dir.foreach("logs") do |file_name|
            if file_name.length > 3 && file_name[-4,4] == ".log"
               puts "Deleting 'logs#{File::SEPARATOR}#{file_name}'"
               File.delete("logs#{File::SEPARATOR}#{file_name}")
            end
         end
      else
         # Create the logs directory.
         Dir.mkdir("logs")
      end
   end
   
   def teardown
   end

   def test_apply
      LogJam.configure(nil)
      
      assert_equal(3, LogJam.names.size)
      assert_equal(true, LogJam.names.include?("silent"))
      assert_equal(true, LogJam.names.include?("verbose"))
      assert_equal(true, LogJam.names.include?("class01"))
      assert_not_equal(LogJam.get_logger("silent"), LogJam.get_logger("verbose"))
      assert_equal(LogJam.get_logger, LogJam.get_logger("silent"))
   end
end
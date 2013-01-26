#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'json'
require 'logjam'
require 'pp'
require 'test/unit'
require 'yaml'

class MyClass
   LogJam.apply(self, "my_class")
end

class TestLogJamConfigure < Test::Unit::TestCase
   def setup
      if File.exists?("logs")
         # Delete all existing log files.
         Dir.foreach("logs") do |file_name|
            if file_name.length > 3 && file_name[-4,4] == ".log"
               File.delete("logs#{File::SEPARATOR}#{file_name}")
            end
         end
      else
         # Create the logs directory.
         Dir.mkdir("logs")
      end
      LogJam.configure({:loggers => [{:name => "my_class",
                                      :file => "logs/my_class.log"},
                                     {:name => "other",
                                      :file => "logs/other.log"}]})
   end
   
   def teardown
   end

   def test_apply
      sizes = [File.size("logs/my_class.log"), File.size("logs/other.log")]
      
      MyClass.log.debug "Line one."
      (MyClass.new).log.debug "Line two."
      assert_equal(true, (File.size("logs/my_class.log") > sizes[0]))
      assert_equal(true, (File.size("logs/other.log") == sizes[1]))
      
      sizes = [File.size("logs/my_class.log"), File.size("logs/other.log")]
      LogJam.get_logger("other").info "Blah-de-blah"
      assert_equal(true, (File.size("logs/my_class.log") == sizes[0]))
      assert_equal(true, (File.size("logs/other.log") > sizes[1]))
   end
end
#! /usr/bin/env ruby
# Copyright (c) 2013, Peter Wood.
# See the license.txt for details of the licensing of the code in this file.

require 'json'
require 'logjam'
require 'minitest/autorun'
require 'minitest/spec'
require 'yaml'

describe "LogJam.configure method" do
   it "configures the LogJam internals correct for a basic set up" do
      settings = {:loggers => [{:name => "logger01",
                                :file => "STDOUT"},
                               {:name => "logger02",
                                :file => "STDOUT"}]}
      LogJam.configure(settings)

      LogJam.names.empty?.must_equal(false)
      LogJam.names.size.must_equal(2)
      LogJam.names.include?("logger01").must_equal(true)
      LogJam.names.include?("logger02").must_equal(true)

      LogJam.get_logger.wont_be_nil
      LogJam.get_logger("logger01").wont_be_nil
      LogJam.get_logger("logger02").wont_be_nil

      LogJam.get_logger.wont_equal(LogJam.get_logger("logger01"))
      LogJam.get_logger.wont_equal(LogJam.get_logger("logger02"))
      LogJam.get_logger("logger01").wont_equal(LogJam.get_logger("logger02"))
   end

   it "configures logger aliases correctly" do
      settings = {:loggers => [{:name => "logger03",
                                :file => "STDOUT"},
                               {:name => "logger04",
                                :file => "STDOUT"}],
                  :aliases => {"other01" => "logger04",
                               "other02" => "logger03"}}
      LogJam.configure(settings)

      LogJam.names.empty?.must_equal(false)
      LogJam.names.size.must_equal(4)
      LogJam.names.include?("logger03").must_equal(true)
      LogJam.names.include?("logger04").must_equal(true)
      LogJam.names.include?("other01").must_equal(true)
      LogJam.names.include?("other02").must_equal(true)

      LogJam.get_logger.wont_be_nil
      LogJam.get_logger("logger03").wont_be_nil
      LogJam.get_logger("logger04").wont_be_nil
      LogJam.get_logger("other01").wont_be_nil
      LogJam.get_logger("other02").wont_be_nil

      LogJam.get_logger.wont_equal(LogJam.get_logger("logger03"))
      LogJam.get_logger.wont_equal(LogJam.get_logger("logger04"))
      LogJam.get_logger("logger03").wont_equal(LogJam.get_logger("logger04"))
      LogJam.get_logger("logger03").must_equal(LogJam.get_logger("other02"))
      LogJam.get_logger("logger04").must_equal(LogJam.get_logger("other01"))
   end

   describe "when using a configuration file" do
      describe "that contains a YAML configuration" do
         def setup
            configuration = {:loggers => [{:name    => 'logger05',
                                           :file    => 'STDOUT',
                                           :level   => 'UNKNOWN',
                                           :default => true},
                                          {:name    => 'logger06',
                                           :file    => './test_file.log'}],
                            :aliases => {'alias01' => 'logger06',
                                         'alias02' => 'logger05'}}
            LogJam::DEFAULT_FILE_NAMES.each do |file_name|
               File.delete(file_name) if File.exist?(file_name)
            end
            File.open("./logging.yml", "w") do |file|
               file << configuration.to_yaml
            end
         end

         def teardown
            LogJam::DEFAULT_FILE_NAMES.each do |file_name|
               File.delete(file_name) if File.exist?(file_name)
            end
         end

         it "gets configured correctly" do
            LogJam.configure(nil)

            LogJam.names.empty?.must_equal(false)
            LogJam.names.size.must_equal(4)
            LogJam.names.include?("logger05").must_equal(true)
            LogJam.names.include?("logger06").must_equal(true)
            LogJam.names.include?("alias01").must_equal(true)
            LogJam.names.include?("alias02").must_equal(true)

            LogJam.get_logger.wont_be_nil
            LogJam.get_logger("logger05").wont_be_nil
            LogJam.get_logger("logger05").wont_be_nil
            LogJam.get_logger("alias01").wont_be_nil
            LogJam.get_logger("alias02").wont_be_nil

            LogJam.get_logger.must_equal(LogJam.get_logger("logger05"))
            LogJam.get_logger.wont_equal(LogJam.get_logger("logger06"))
            LogJam.get_logger("logger05").wont_equal(LogJam.get_logger("logger06"))
            LogJam.get_logger("logger05").must_equal(LogJam.get_logger("alias02"))
            LogJam.get_logger("logger06").must_equal(LogJam.get_logger("alias01"))
         end
      end

      describe "that contains a JSON configuration" do
         def setup
            configuration = {:loggers => [{:name    => 'logger07',
                                           :file    => 'STDOUT',
                                           :level   => 'UNKNOWN',
                                           :default => true},
                                          {:name    => 'logger08',
                                           :file    => './test_file.log'}],
                            :aliases => {'alias03' => 'logger08',
                                         'alias04' => 'logger07'}}
            LogJam::DEFAULT_FILE_NAMES.each do |file_name|
               File.delete(file_name) if File.exist?(file_name)
            end
            File.open("./logging.json", "w") do |file|
               file << configuration.to_json
            end
         end

         def teardown
            LogJam::DEFAULT_FILE_NAMES.each do |file_name|
               File.delete(file_name) if File.exist?(file_name)
            end
         end

         it "gets configured correctly" do
            LogJam.configure(nil)

            LogJam.names.empty?.must_equal(false)
            LogJam.names.size.must_equal(4)
            LogJam.names.include?("logger07").must_equal(true)
            LogJam.names.include?("logger08").must_equal(true)
            LogJam.names.include?("alias03").must_equal(true)
            LogJam.names.include?("alias04").must_equal(true)

            LogJam.get_logger.wont_be_nil
            LogJam.get_logger("logger07").wont_be_nil
            LogJam.get_logger("logger08").wont_be_nil
            LogJam.get_logger("alias03").wont_be_nil
            LogJam.get_logger("alias04").wont_be_nil

            LogJam.get_logger.must_equal(LogJam.get_logger("logger07"))
            LogJam.get_logger.wont_equal(LogJam.get_logger("logger08"))
            LogJam.get_logger("logger07").wont_equal(LogJam.get_logger("logger08"))
            LogJam.get_logger("logger07").must_equal(LogJam.get_logger("alias04"))
            LogJam.get_logger("logger08").must_equal(LogJam.get_logger("alias03"))
         end
      end
   end
end
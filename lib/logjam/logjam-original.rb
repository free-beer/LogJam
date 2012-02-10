#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'logger'

# This module defines the name space to be used by all code within the
# LogJam library.
module LogJam
   # Module constants.
   LOG_FILE  = :log_file
   LOG_ROLL  = :log_roll_period
   LOG_LEVEL = :log_level

   # Module wide property declarations.
   @@logjam_logger = nil
   
   # This method fetches the module logger, initializing it and creating it if
   # it doesn't yet exist.
   #
   # ==== Parameters
   # configuration::  The configuration to use in setting up the logging.
   #                  Defaults to nil to indicate the creation of a logger based
   #                  on STDOUT.
   def log(configuration=nil)
      LogJam.configure(configuration) if !configuration.nil? || @@logjam_logger.nil?
      @@logjam_logger
   end
   
   # This method updates the logger associated with the module.
   #
   # ==== Parameters
   # logger::  The new logger for the module.
   def log=(logger)
      LogJam.log = logger
   end

   # This method updates the logger associated with the module.
   #
   # ==== Parameters
   # logger::  The new logger for the module.
   def self.log=(logger)
      @@logjam_logger.logger = logger
   end
   
   # This method is used to install the LogJam capabilities into a target class.
   #
   # ==== Parameters
   # target:: The class that is to be 'logified'.
   def self.logify(target)
      target.extend(self)
   end
   
   # This method sets up the module logging from configuration.
   #
   # ==== Parameters
   # configuration::  The configuration to use when setting up logging.
   def self.configure(configuration)
      if !configuration.nil?
         if @@logjam_logger.nil?
            # Create the logger.
            if LogJam.is_configured?(configuration, LOG_FILE)
               file_name       = LogJam.get_value(configuration, LOG_FILE)
               period          = LogJam.get_value(configuration, LOG_ROLL)
               @@logjam_logger = LogJamLogger.new(file_name, period)
            else
               @@logjam_logger = LogJamLogger.new(STDOUT)
            end
         else
            # Change the internally held logger.
            if LogJam.is_configured?(configuration, LOG_FILE)
               file_name              = LogJam.get_value(configuration, LOG_FILE)
               period                 = LogJam.get_value(configuration, LOG_ROLL)
               @@logjam_logger.logger = Logger.new(file_name, period)
            else
               @@logjam_logger.logger = Logger.new(STDOUT)
            end
         end
      else
         if @@logjam_logger.nil?
            @@logjam_logger = LogJamLogger.new(STDOUT)
         else
            @@logjam_logger.logger = Logger.new(STDOUT)
         end
      end

      # Set the logger level.
      level = LogJam.get_value(configuration, LOG_LEVEL, "DEBUG")
      case level.downcase
         when "info"
            level = Logger::INFO
         when "warn"
            level = Logger::WARN
         when "error"
            level = Logger::ERROR
         when "fatal"
            level = Logger::FATAL
         when "unknown"
            level = Logger::UNKNOWN
         else
            level = Logger::DEBUG
      end
      @@logjam_logger.level = level
      @@logjam_logger
   end
   
   private
   
   # This method encapsulates the functionality for extracting named value from
   # a Hash given a key.
   def self.get_value(configuration, name, default=nil)
      value = default
      if !configuration.nil?
         if configuration.include?(name)
            value = configuration[name]
         elsif configuration.include?(name.to_s)
            value = configuration[name.to_s]
         end
      end
      value
   end
   
   # This method is used internally by the module to determine whether a
   # configuration setting has been provided.
   def self.is_configured?(configuration, name)
      configuration.include?(name) || configuration.include?(name.to_s)
   end
end

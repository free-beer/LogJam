#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'json'
require 'logger'
require 'stringio'
require 'yaml'

# This module defines the name space to be used by all code within the
# LogJam library.
module LogJam
   # Module constants.
   LOGGER_NAME               = :name
   LOGGER_FILE               = :file
   LOGGER_ROTATION           = :rotation
   LOGGER_MAX_SIZE           = :max_size
   LOGGER_LEVEL              = :level
   LOGGER_DEFAULT            = :default
   LOGGER_DATETIME_FORMAT    = :datetime_format
   DEFAULT_FILE_NAMES        = [".#{File::SEPARATOR}logging.yaml",
                                ".#{File::SEPARATOR}logging.yml",
                                ".#{File::SEPARATOR}logging.json",
                                ".#{File::SEPARATOR}config#{File::SEPARATOR}logging.yaml",
                                ".#{File::SEPARATOR}config#{File::SEPARATOR}logging.yml",
                                ".#{File::SEPARATOR}config#{File::SEPARATOR}logging.json"]

   # Module static properties.
   @@logjam_modules = {}
   @@logjam_loggers = {}
   
   # This method is used to configure the LogJam module with the various loggers
   # it will use.
   #
   # ==== Parameters
   # source::  Either a String containing the path and name of the configuration
   #           file containing the logging set up, an IO object from which the
   #           configuration details can be read, a Hash containing a logging
   #           configuration or nil.
   def self.configure(source)
      @@logjam_modules = {}
      @@logjam_loggers = {}
      
      # Check for default files if nil was passed in.
      source = LogJam.find_default_file if source.nil?

      if !source.kind_of?(Hash) && !source.nil?
         io            = source.kind_of?(String) ? File.new(source) : source
         type          = source.kind_of?(String) ? LogJam.guess_format(source) : nil
         LogJam.process_configuration(LogJam.load_configuration(io, type))
      elsif source.nil?
         LogJam.process_configuration({})
      else
         LogJam.process_configuration(source)
      end
   end
   
   # This method is used to install logging facilities at the class level for a
   # given class. Once 'logified' a class will possess two new methods. The
   # first, #log(), retrieves the logger associated with the class. The second,
   # #log=(), allows the assignment of the logger associated with the class.
   # Note that changing the logger associated with a class will impact all other
   # classes that use the same logger.
   #
   # ==== Parameters
   # target::  The target class that is to be extended.
   # name::    The name of the logger to be used by the class. Defaults to nil
   #           to indicate use of the default logger.
   def self.apply(target, name=nil)
      target.extend(LogJam.get_module(name))
      target.send(:define_method, :log) {LogJam.get_logger(name)} if !target.method_defined?(:log)
   end

   # This method attempts to fetch the logger for a specified name. If this
   # logger does not exist then a default logger will be returned instead.
   #
   # ==== Parameters
   # name::  The name of the logger to retrieve.
   def self.get_logger(name=nil)
      LogJam.process_configuration(nil) if @@logjam_loggers.empty?
      @@logjam_loggers.fetch(name, @@logjam_loggers[nil])
   end

   # This method fetches a list of the names currently defined within the LogJam
   # internal settings.
   def self.names
      @@logjam_loggers.keys.compact
   end

   # A convenience mechanism that provides an instance level access to the
   # class level logger.
   def log
      self.class.log
   end
   
   private
   
   # This method fetches the module associated with a name. If the module does
   # not exist the default module is returned instead.
   #
   # ==== Parameters
   # name:: The name associated with the module to return.
   def self.get_module(name)
      LogJam.create_module(name)
   end

   # This method attempts to load a LogJam configuration from an IO object.
   #
   # ==== Parameters
   # source::  The IO object to read the configuration details from.
   # type::    An indicator of the format being used for the configuration. This
   #           should be :yaml, :json or nil. Nil indicates that the library
   #           will try to load the file in various formats.
   def self.load_configuration(source, type)
      configuration = nil
      if ![:yaml, :json].include?(type)
         begin
            # Read in the full details of the configuration.
            details = source.read
            
            # Try YAML format first.
            begin
               configuration = LogJam.load_yaml_configuration(StringIO.new(details))
            rescue LogJamError
               # Assume wrong format and ignore.
               configuration = nil
            end
            
            if configuration.nil?
               # Try JSON format second.
               begin
                  configuration = LogJam.load_json_configuration(StringIO.new(details))
               rescue LogJamError
                  # Assume wrong format and ignore.
                  configuration = nil
               end
            end
         rescue => error
            raise LogJamError.new("Exception raised loading the LogJam "\
                                  "configuration.\nCause: #{error}", error)
         end
         
         # Check if the load was successful.
         if configuration.nil?
            raise LogJamError.new("Error loading the LogJam configuration. The "\
                                  "configuration is not in a recognised format "\
                                  "or contains errors. The configuration must "\
                                  "be in either YAML or JSON format.")
         end
      elsif type == :json
         configuration = LogJam.load_json_configuration(source)
      elsif type == :yaml
         configuration = LogJam.load_yaml_configuration(source)
      end
      configuration
   end

   # This method attempts to load a configuration for the LogJam library from
   # a file. The configuration is expected to be in YAML format.
   #
   # ==== Parameters
   # source::  An IO object from which the configuration will be read.
   def self.load_yaml_configuration(source)
      begin
         YAML.load(source)
      rescue => error
         raise LogJamError.new("Error loading LogJam configuration from YAML "\
                               "source.\nCause: #{error}", error)
      end
   end

   # This method attempts to load a configuration for the LogJam library from
   # a file. The configuration is expected to be in JSON format.
   #
   # ==== Parameters
   # source::  An IO object from which the configuration will be read.
   def self.load_json_configuration(source)
      begin
         JSON.parse(source.read)
      rescue => error
         raise LogJamError.new("Error loading LogJam configuration from JSON "\
                               "source.\nCause: #{error}", error)
      end
   end
   
   # This method processes a logger configuration and generates the appropriate
   # set of loggers and internal objects from it.
   #
   # ==== Parameters
   # configuration::  The configuration to be processed. If this is nil or empty
   # then a single default logger is generated that writes to the standard
   # output stream.
   def self.process_configuration(configuration)
      if !configuration.nil? && !configuration.empty?
         key = (configuration.include?(:loggers) ? :loggers : "loggers")
         if configuration.include?(key)
            loggers = configuration[key]
            if loggers.kind_of?(Array)
               configuration[key].each do |definition|
                  LogJam.create_logger(definition)
               end
            elsif loggers.kind_of?(Hash)
               LogJam.create_logger(loggers)
            else
               raise LogJamError.new("The loggers configuration entry is in "\
                                     "an unrecognised format. Must be either "\
                                     "a Hash or an Array.")
            end
         end
      end

      # Set up any aliases that have been specified.
      if !@@logjam_loggers.empty? && !configuration.nil? && !configuration.empty?
         key = (configuration.include?(:loggers) ? :aliases : "aliases")
         if configuration.include?(key)
            configuration[key].each do |name, equivalent|
               @@logjam_loggers[name] = LogJam.get_logger(equivalent)
               @@logjam_modules[name] = LogJam.get_module(equivalent)
            end
         end
      end

      # Create a default logger if one hasn't been specified.
      if @@logjam_loggers[nil].nil?
         LogJam.create_logger({LOGGER_FILE => "STDOUT"})
      end
   end

   # This method is used to create an anonymous module under a given name (if it
   # doesn't already exist) and return it to the caller.
   #
   # ==== Parameters
   # name::  The name to create the module under.
   def self.create_module(name)
      if !@@logjam_modules.include?(name)
         # Create the anonymous module and add methods to it.
         @@logjam_modules[name] = Module.new
         @@logjam_modules[name].send(:define_method, :log) do
            LogJam.get_logger(name)
         end
         @@logjam_modules[name].send(:define_method, :log=) do |logger|
            LogJam.get_logger(name).logger = logger
         end
      end
      @@logjam_modules[name]
   end

   # This method extends a specified class with a named module.
   #
   # ==== Parameters
   # target::  The class that is to be extended.
   # name::    The name of the module to extend the class with.
   def self.extend_class(target, name)
      target.extend(LogJam.get_module(name))
   end
   
   # This method attempts to guess the format that configuration details will be
   # in given a file name. Guessing is done by looking at the file's extension.
   # Files ending in '.yaml' or '.yml' are considered YAML. Files ending '.json'
   # are considered JSON. The method returns nil if the path passed in has
   # neither of these extensions.
   #
   # ==== Parameters
   # path::  The path and name of the file to make the guess from.
   def self.guess_format(path)
      type = nil
      if path.nil? && path.include?(".")
         offset    = path.length - path.reverse.index(".")
         extension = path[offset, path.length - offset].downcase
         case extension
            when 'yaml', 'yml'
               type = :yaml

            when 'json'
               type = :json
         end
      end
      type
   end
   
   # This method creates a logger from a given definition. A definition should
   # be a Hash containing the values that are used to configure the Logger with.
   #
   # ==== Parameters
   # definition::  A Hash containing the configuration details for the logger.
   def self.create_logger(definition)
      # Fetch the configuration values.
      name     = LogJam.get_value(definition, LOGGER_NAME)
      path     = LogJam.get_value(definition, LOGGER_FILE)
      rotation = LogJam.get_value(definition, LOGGER_ROTATION)
      max_size = LogJam.get_value(definition, LOGGER_MAX_SIZE)
      level    = LogJam.get_value(definition, LOGGER_LEVEL)
      default  = LogJam.get_value(definition, LOGGER_DEFAULT)
      
      device = nil
      if ["STDOUT", "STDERR"].include?(path)
         device = (path == "STDOUT" ? STDOUT : STDERR)
      else
         device = path
      end

      if rotation.kind_of?(String) && /^\s*\d+\s*$/ =~ rotation
         rotation = rotation.to_i
         rotation = 0 if rotation < 0
      end

      if !max_size.nil? && max_size.kind_of?(String)
         max_size = max_size.to_i
      end
      max_size = 1048576 if !max_size.nil? && max_size < 1024

      if !level.nil?
         case level.downcase
            when 'info'
               level = Logger::INFO
   
            when 'warn'
               level = Logger::WARN
   
            when 'error'
               level = Logger::ERROR
   
            when 'fatal'
               level = Logger::FATAL
   
            when 'unknown'
               level = Logger::UNKNOWN
   
            else
               level = Logger::DEBUG
         end
      else
         level = Logger::DEBUG
      end

      if default != true
         if default.kind_of?(String)
            default = ["true", "yes", "on", "1"].include?(default.downcase)
         else
            default = false
         end
      end

      # Create the actual logger and associated module.
      logger                 = LogJamLogger.new(device, rotation, max_size)
      logger.level           = level
      logger.name            = name
      logger.progname        = name
      @@logjam_loggers[name] = logger
      logger_module          = LogJam.create_module(name)
      if default
         @@logjam_loggers[nil]  = logger
         @@logjam_modules[nil]  = logger_module
      end
      logger
   end
   
   # This method attempts to fetch a value from a Hash. The key passed to the
   # method should be a symbol and this will be checked for first. If this is
   # not found then a check is made for the string equivalent. The first of
   # these that is present in the Hash generates the value returned. If neither
   # is present in the Hash then nil is returned.
   #
   # ==== Parameters
   # source::  The Hash that will be checked for the value.
   # key::     A symbol that will be checked as the key for the value.
   def self.get_value(source, key)
      if source.include?(key)
         source[key]
      elsif source.include?(key.to_s)
         source[key.to_s]
      else
         nil
      end
   end
   
   # This module level method is used to check for the existence of a
   # configuration file under one or a standard set of names. This method is
   # only used whenever the configure method is called and either passed nil
   # or no parameter.
   def self.find_default_file
      file_name = nil
      DEFAULT_FILE_NAMES.each do |name|
         file_name = name if File.exists?(name) && File.readable?(name)
         break if !file_name.nil?
      end
      file_name
   end
end

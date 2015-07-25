#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'forwardable'
require 'logger'
require 'configurative'
require 'logjam/version'
require 'logjam/exceptions'
require 'logjam/configuration'
require 'logjam/logger'
require 'logjam/object'

module LogJam
  # Module constants.
  LEVEL_MAP                 = {"debug"   => Logger::DEBUG,
                               "info"    => Logger::INFO,
                               "warn"    => Logger::WARN,
                               "error"   => Logger::ERROR,
                               "fatal"   => Logger::FATAL,
                               "unknown" => Logger::UNKNOWN}
  STREAM_MAP                = {"stdout" => STDOUT,
                               "stderr" => STDERR}

  # Module static properties.
  @@logjam_modules  = {}
  @@logjam_loggers  = {}
  @@logjam_contexts = {}

  # This method is used to configure the LogJam module with the various loggers
  # it will use.
  #
  # ==== Parameters
  # source::  Either a Hash containing the configuration to be used or nil to
  #           indicate the use of default configuration settings.
  def self.configure(source=nil)
    @@logjam_modules = {}
    @@logjam_loggers = {}
    LogJam.process_configuration(source ? source : Configuration.instance)
  end

  # This method is used to install logging facilities at the class level for a
  # given class. Once 'logified' a class will possess two new methods. The
  # first, #log(), retrieves the logger associated with the class. The second,
  # #log=(), allows the assignment of the logger associated with the class.
  # Note that changing the logger associated with a class will impact all other
  # classes that use the same logger.
  #
  # ==== Parameters
  # target::   The target class that is to be extended.
  # name::     The name of the logger to be used by the class. Defaults to nil
  #            to indicate use of the default logger.
  # context::  A Hash of additional parameters that are specific to the class
  #            to which LogJam is being applied.
  def self.apply(target, name=nil, context={})
    @@logjam_contexts[target] = {}.merge(context)
    target.extend(LogJam.get_module(name, @@logjam_contexts[target]))
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
  # name::     The name associated with the module to return.
  # context::  The context that applies to the module to be retrieved.
  def self.get_module(name, context={})
    LogJam.create_module(name)
  end

  # This method processes a logger configuration and generates the appropriate
  # set of loggers and internal objects from it.
  #
  # ==== Parameters
  # settings::  A collection of the settings to be processed.
  def self.process_configuration(settings)
    settings = Configurative::SettingsParser.new.parse(settings) if settings.kind_of?(Hash)
    if settings && !settings.empty?
      loggers = settings.loggers
      if loggers
         if loggers.kind_of?(Array)
            loggers.each {|definition| LogJam.create_logger(definition)}
         elsif loggers.kind_of?(Hash)
            LogJam.create_logger(loggers)
         else
            raise Error, "The loggers configuration entry is in an "\
                         "unrecognised format. Must be either a Hash or an "\
                         "Array."
         end
      end

      aliases = settings.aliases
      if aliases
         aliases.each do |name, equivalent|
            @@logjam_loggers[name] = @@logjam_loggers[equivalent]
            @@logjam_modules[name] = LogJam.get_module(equivalent)
         end
      end
    end

    # Create a default logger if one hasn't been specified.
    LogJam.create_logger({default: true, file: "STDOUT"}) if @@logjam_loggers[nil].nil?
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

  # This method creates a logger from a given definition. A definition should
  # be a Hash containing the values that are used to configure the Logger with.
  #
  # ==== Parameters
  # definition::  A Hash containing the configuration details for the logger.
  def self.create_logger(definition)
    # Fetch the configuration values.
    definition = to_definition(definition)
    rotation   = definition.rotation
    max_size   = definition.max_size
    device     = STREAM_MAP.fetch(definition.file.downcase.strip, definition.file)

    if rotation.kind_of?(String) && /^\s*\d+\s*$/ =~ rotation
      rotation = rotation.to_i
      rotation = 0 if rotation < 0
    end

    max_size = max_size.to_i if !max_size.nil? && max_size.kind_of?(String)
    max_size = 1048576 if !max_size.nil? && max_size < 1024

    # Create the actual logger and associated module.
    logger                 = LogJam::Logger.new(device, rotation, max_size)
    logger.level           = LEVEL_MAP.fetch(definition.level.downcase.strip, Logger::DEBUG)
    logger.name            = definition.name
    logger.progname        = definition.name
    @@logjam_loggers[definition.name] = logger
    logger_module          = LogJam.create_module(name)
    if definition.default
      @@logjam_loggers[nil]  = logger
      @@logjam_modules[nil]  = logger_module
    end
    logger
  end

  def self.to_definition(settings)
    settings = Configurative::SettingsParser.new.parse(settings) if settings.kind_of?(Hash)
    settings.file  = "stdout" if !settings.include?(:file) || settings.file == ""
    settings.level = "debug" if !settings.include?(:level) || settings.level == ""
    settings
  end
end

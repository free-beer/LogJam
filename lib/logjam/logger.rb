#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

module LogJam
  # This class represents a specialization of the Ruby Logger class. The class
  # retains a Ruby Logger instance within itself and delegates all standard
  # logger calls to this instance. This allows for changes to the underlying
  # logger without changing the containing one, thus bypassing people caching
  # an instance.
  class Logger < ::Logger
    extend Forwardable
    def_delegators :@log, :add, :close, :datetime_format, :datetime_format=,
                          :debug, :debug?, :error, :error?, :fatal, :fatal?,
                          :formatter, :formatter=, :info, :info?, :level,
                          :level=, :progname, :progname=, :sev_threshold,
                          :sev_threshold=, :unknown, :warn, :warn?

    # Constructor for the Logger class. All parameters are passed
    # straight through to create a standard Ruby Logger instance except
    # when the first parameter is a Logger instance. In this case the
    # Logger passed in is used rather than creating a new one.
    #
    # ==== Parameters
    # logdev::      The log device to be used by the logger. This should be
    #               be a String containing a file path/name, an IO object that
    #               the logging details will be written to or another logger
    #               that you want to wrap.
    # shift_age::   The maximum number of old log files to retain or a String
    #               containing the rotation frequency for the log.
    # shift_size::  The maximum size that the logging output will be allowed
    #               to grow to before rotation occurs.
    def initialize(logdev, shift_age=0, shift_size=1048576)
      @log = (logdev.kind_of?(::Logger) ? logdev : ::Logger.new(logdev, shift_age, shift_size))
      @name = nil
    end

    # Attribute accessor/mutator declaration.
    attr_accessor :name

    # This method fetches the standard Ruby Logger instance contained within
    # a Logger object.
    def logger
      @log
    end

    # This method updates the logger instance contained within a Logger
    # object.
    #
    # ==== Parameters
    # logger::  The object to set as the contained logger. This should be an
    #           instance of the standard Ruby Logger class or something
    #           compatible with this.
    def logger=(logger)
      @log = logger
    end

    # Aliases
    alias :log :add
  end
end

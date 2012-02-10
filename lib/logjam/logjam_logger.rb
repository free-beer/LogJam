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
   class LogJamLogger < Logger
      # Constructor for the LogJamLogger class. All parameters are passed
      # straight through to create a standard Ruby Logger instance except
      # when the first parameter is a Logger instance. In this case the
      # Logger passed in is used rather than creating a new one.
      #
      # ==== Parameters
      # logdev::      The log device to be used by the logger. This should
      #               either be a String containing a file path/name or an IO
      #               object that the logging details will be written to.
      # shift_age::   The maximum number of old log files to retain or a String
      #               containing the rotation frequency for the log.
      # shift_size::  The maximum size that the loggin output will be allowed
      #               to grow to before rotation occurs.
      def initialize(logdev, shift_age=0, shift_size=1048576)
         if logdev.kind_of?(Logger)
            @log = logdev
         else
            @log = Logger.new(logdev, shift_age, shift_size)
         end
         @name = nil
      end
      
      # Attribute accessor/mutator declaration.
      attr_accessor :name

      # Overload of the property fetcher provided by the contained Logger
      # instance.
      def formatter
         @log.formatter
      end

      # Overload of the property updater provided by the contained Logger
      # instance.
      def formatter=(formatter)
         @log.formatter = formatter
      end

      # Overload of the property fetcher provided by the contained Logger
      # instance.
      def level
         @log.level
      end

      # Overload of the property updater provided by the contained Logger
      # instance.
      def level=(level)
         @log.level = level
      end

      # Overload of the property fetcher provided by the contained Logger
      # instance.
      def progname
         @log.progname
      end

      # Overload of the property updater provided by the contained Logger
      # instance.
      def progname=(name)
         @log.progname = name
      end

      # Overload of the property fetcher provided by the contained Logger
      # instance.
      def sev_threshold
         @log.sev_threshold
      end

      # Overload of the property updater provided by the contained Logger
      # instance.
      def sev_threshold=(threshold)
         @log.sev_threshold = threshold
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def <<(message)
         @log << message
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def add(severity, message=nil, program=nil, &block)
         @log.add(severity, message, program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def close
         @log.close
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def datetime_format
         @log.datetime_format
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def datetime_format=(format)
         @log.datetime_format = format
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def debug(program=nil, &block)
         @log.debug(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def debug?
         @log.debug?
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def error(program=nil, &block)
         @log.error(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def error?
         @log.error?
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def fatal(program=nil, &block)
         @log.fatal(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def fatal?
         @log.fatal?
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def info(program=nil?, &block)
         @log.info(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def info?
         @log.info?
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def unknown(program=nil, &block)
         @log.unknown(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def warn(program=nil, &block)
         @log.warn(program, &block)
      end

      # Overload of the corresponding method on the Logger class to pass the
      # call straight through to the contained logger.
      def warn?
         @log.warn?
      end

      # This method fetches the standard Ruby Logger instance contained within
      # a LogJamLogger object.
      def logger
         @log
      end
      
      # This method updates the logger instance contained within a LogJamLogger
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

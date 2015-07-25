#! /usr/bin/env ruby
#
# Copyright (c), 2012 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

require 'stringio'

module LogJam
   # This class provides the exception class used by the LogJam library.
   class Error < StandardError
      # Constructor for the LogJam::Error class.
      #
      # ==== Parameters
      # message::  The message to be associated with the error.
      # cause::    Any underlying exception to be associated with the error.
      #            Defaults to nil.
      def initialize(message, cause=nil)
         super(message)
         @cause = cause
      end
      attr_reader :cause
   end
end

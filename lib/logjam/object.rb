#! /usr/bin/env ruby
#
# Copyright (c), 2013 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

class Object
   # This method provides an instance level accessor to obtain a logger. Unless
   # a name is specified the logger returned is the default one.
   #
   # ==== Parameters
   # name::  The name of the logger to retrieve. Defaults to nil to indicate
   #         that the default logger should be returned.
   def log(name=nil)
      LogJam.get_logger(name)
   end

   # This method provides a class level accessor to obtain a logger. Unless a
   # name is specified the logger returned is the default one.
   #
   # ==== Parameters
   # name::  The name of the logger to retrieve. Defaults to nil to indicate
   #         that the default logger should be returned.
   def self.log(name=nil)
      LogJam.get_logger(name)
   end

   # This method allows a class to specify the name of the logger that it uses
   # once, generally within the class definition.
   #
   # ==== Parameters
   # name::     The name of the logger used by the class.
   # context::  A Hash of additional parameters that are specific to the class
   #            to which LogJam is being applied.
   def self.set_logger_name(name, context={})
      LogJam.apply(self, name, context)
   end
end
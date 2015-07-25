#! /usr/bin/env ruby
#
# Copyright (c), 2015 Peter Wood
# See the license.txt for details of the licensing of the code in this file.

module LogJam
  class Configuration < Configurative::Settings
    sources *(Dir.glob(File.join(Dir.getwd, "logging.{yml,yaml,json}")) +
              Dir.glob(File.join(Dir.getwd, "config", "logging.{yml,yaml,json}")) +
              Dir.glob(File.join(Dir.getwd, "**", "application.{yml,yaml,json}")))
    section "logging"
  end
end

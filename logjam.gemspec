# Copyright (c) 2011, Peter Wood
# All rights reserved.
require File.expand_path('../lib/logjam/version', __FILE__)

spec = Gem::Specification.new do |s|
   s.name        = "logjam"
   s.version     = LogJam::VERSION
   s.platform    = Gem::Platform::RUBY
   s.authors     = ["Black North"]
   s.email       = "ruby@blacknorth.com"
   s.summary     = "A library to aggregate logging."
   s.description = "LogJam is a library to simplify the use of logging across libraries and applications."
   s.homepage    = "https://github.com/free-beer/LogJam"

   s.add_development_dependency("rspec")
   s.add_dependency("json")
   s.add_dependency("configurative")

   s.files        = Dir.glob("{bin,lib}/**/*") + %w(license.txt README)
   s.require_path = 'lib'
end

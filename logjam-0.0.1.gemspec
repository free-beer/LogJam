# Copyright (c) 2011, Peter Wood
# All rights reserved.

spec = Gem::Specification.new do |s|
   s.name        = "logjam"
   s.version     = "0.0.1"
   s.platform    = Gem::Platform::RUBY
   s.authors     = ["Black North"]
   s.email       = "ruby@blacknorth.com"
   s.summary     = "A library to aggregate logging."
   s.description = "LogJam is a library to simplify the use of logging across libraries and applications."
   
   s.add_dependency("json")

   s.files        = Dir.glob("{bin,lib}/**/*") + %w(license.txt README)
   s.require_path = 'lib'
end
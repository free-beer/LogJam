require "bundler/gem_tasks"
require "yaml"

@home_dir     = Dir.getwd

namespace :test do
   desc "Run unit tests. Set TESTS to run individual test files."
   task :unit do
      test_list = []
      if ENV['TESTS']
         ENV['TESTS'].split(',').each do |name|
            file_name = "./test/unit/logjam_#{name}_spec.rb"
            if File.exist?(file_name)
               test_list << file_name
            else
               STDERR.puts "WARNING: The #{file_name} unit test file does not exist, ignoring it."
            end
         end
      else
         test_list = Dir.glob('./test/unit/**/*.rb')
      end
      test_list.each do |test_file|
         puts "Test File: #{test_file}"
         sh %{bundle exec ruby -I./lib #{test_file}}
      end
   end
end
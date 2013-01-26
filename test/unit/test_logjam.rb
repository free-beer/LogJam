gem 'test-unit', ">= 2.0.0"
require 'test/unit'
require 'json'
require 'yaml'

module SuiteUtilities
   CONFIGURATION = {:loggers => [{:name    => 'silent',
                                  :file    => 'STDOUT',
                                  :level   => 'UNKNOWN',
                                  :default => true},
                                 {:name    => 'verbose',
                                  :file    => 'logs/test_logjam_configure.log'}],
                    :aliases => {'class01' => 'verbose'}}

   def clear_logs
      files = Dir.glob("./logs/*")
      if !files.empty?
         files.each do |file|
            #puts "Deleting the '#{file}' file."
            File.delete(file)
         end
      end
   end

   def clear_configurations
      files = Dir.glob("./config/*")
      if !files.empty?
         files.each do |file|
            #puts "Deleting the '#{file}' file."
            File.delete(file)
         end
      end
   end

   def write_yaml_configuration
      #puts "Creating ./config/logging.yml"
      File.open('./config/logging.yml', 'w') do |file|
         #puts "\n\n#{CONFIGURATION.to_yaml}\n\n"
         file << CONFIGURATION.to_yaml
      end
   end

   def write_json_configuration
      #puts "Creating ./config/logging.json"
      File.open('./config/logging.json', 'w') do |file|
         #puts "\n\n#{CONFIGURATION.to_json}\n\n"
         file << CONFIGURATION.to_json
      end
   end
end

module StartUpAndShutdown
   include SuiteUtilities

   def startup
      if !File.exist?("./config")
         #puts "Creating the ./config directory."
         Dir.mkdir("config")
      end

      if !File.exist?("./logs")
         #puts "Creating the ./logs directory."
         Dir.mkdir("logs")
      end

      clear_logs
      clear_configurations
   end

   def shutdown
      clear_logs
      clear_configurations

      if Dir.exist?("logs")
         #puts "Removing the ./logs directory."
         Dir.rmdir("logs")
      end

      if Dir.exist?("config")
         #puts "Removing the ./config directory."
         Dir.rmdir("config")
      end
   end
end

require 'unit/test_logjam_apply.rb'
require 'unit/test_logjam_file_configure.rb'
require 'unit/test_logjam_hash_configure.rb'
require 'unit/test_default_file_load.rb'

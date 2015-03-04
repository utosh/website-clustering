require File.expand_path('../config/environment', __FILE__)

# Rake.load_rakefile "active_record/railties/databases.rake"

# Load custom rake tasks
FileList["lib/tasks/*.rake"].each do |f|
  Rake.load_rakefile f
end

unless ENV['RACK_ENV'] == "production"
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = FileList[
      'spec/**/*_spec.rb',
      # 'spec/models/**/*_spec.rb',
      # 'spec/lib/**/*_spec.rb'
    ]
  end
end

task :default => :spec

task :environment do
  require File.expand_path("../config/environment", __FILE__)
end

desc "Print out routes"
task :routes => :environment do
  puts "Method\tVersion\tURI Pattern"
  ApplicationAPI.routes.each do |route|
    puts "#{route.route_method}\t#{route.route_version}\t#{route.route_path}"
  end
end

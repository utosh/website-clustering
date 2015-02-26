require File.expand_path('../config/environment', __FILE__)

if ENV['RACK_ENV'] == 'development'
  # puts "Loading NewRelic in developer mode ..."
  # require 'new_relic/rack/developer_mode'
  # use NewRelic::Rack::DeveloperMode
end

# use Rack::Lock
use Rack::Runtime
use Rack::MethodOverride
use Rack::Logger, RecommendApp.config.log_level
use Rack::CommonLogger, Logger.new("log/#{ENV['RACK_ENV']}.log")

if ENV['RACK_ENV'] == 'development'
  use Rack::Reloader, 0 # cooldown time
end

use ActiveRecord::ConnectionAdapters::ConnectionManagement
use ActiveRecord::QueryCache

# run Rack::Cascade.new([])

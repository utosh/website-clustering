require File.expand_path('../boot', __FILE__)

Bundler.require(:default, ENV['RACK_ENV'])

require 'active_support/all'
require 'active_support/dependencies'
ActiveSupport::Dependencies.autoload_paths << "app/models"
ActiveSupport::Dependencies.autoload_paths << "lib"

# Timezone
Time.zone_default = Time.find_zone!('Tokyo')
ActiveRecord::Base.default_timezone = :local

require 'erb'
ActiveRecord::Base.establish_connection(
  YAML.load(ERB.new(File.read("config/database.yml")).result)[ENV['RACK_ENV']]
)

$:.push(File.dirname(File.expand_path(__FILE__)) + '/../lib')
require 'logger_patch'

module Application
  module_function
  def config
    @config ||= Configuration.new
  end
  alias_method :configuration, :config

  def configure
    yield config
    config.freeze # 一度だけconfigure可能
  end

  def env
    ENV['RACK_ENV']
  end

  def root
    @root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  def logger
    @logger ||= begin
      config.logger.level = config.log_level
      config.logger
    end
  end

  def redis_client
    @redis_client ||= begin
      r = Redis::Client.new(config.redis_connection)
      r.logger = logger if config.redis_connection[:debug]
      r
    end
  end

  class Configuration
    attr_accessor :redis_connection, :logger, :log_level, :hostname

    def initialize
      @redis_connection = {host: 'localhost', port: 6379, driver: :hiredis}
      @logger    = Logger.new("log/#{ENV['RACK_ENV']}.log")
      @log_level = Logger::WARN
      @hostname  = "localhost"
    end
  end
end

if Object.const_defined? :FactoryGirl
  FactoryGirl.find_definitions
end

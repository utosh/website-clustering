Application.configure do |config|
  config.redis_connection = {host: "localhost", port: 6379, driver: :hiredis, db: 1}
  config.logger = Logger.new($stdout)
  config.log_level = Logger::WARN
  config.hostname = "localhost"
end

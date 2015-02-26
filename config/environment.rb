ENV['RACK_ENV'] ||= "development"

require File.expand_path('../application', __FILE__)
require File.expand_path("../environments/#{ENV['RACK_ENV']}", __FILE__)

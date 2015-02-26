source 'https://rubygems.org'

ruby '2.1.2'

gem 'rack', "~> 1.6.0"
gem 'rake'
# gem 'sinatra'

# DB
gem 'sqlite3'
gem 'activesupport', "~> 4.2"
gem 'activerecord', "~> 4.2", :require => 'active_record'

# Server
gem 'thin', "~> 1.6"
gem 'selenium-webdriver', '~> 2.44'

# KVS
gem 'redis', '~> 3.2'
gem "hiredis"

gem 'racksh'
gem 'pry'
gem 'pry-rescue'
gem 'tapp'
gem 'natto'

# gem 'newrelic_rpm'

group :development do
  gem 'capistrano', '~> 2.15.5'
  gem 'capistrano-ext'
  gem 'capistrano_colors'
  gem 'railsless-deploy', :require => false
end

group :development, :test do
  gem 'factory_girl'
  gem 'rspec', '~> 3.1', :require => false
end

group :test do
  gem 'rack-test', '~> 0.6'
  gem 'database_cleaner'
  gem 'timecop'
end

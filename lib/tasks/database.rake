namespace :db do
  MIGRATIONS_DIR = 'db/migrate'

  # connect the database
  ActiveRecord::Base.establish_connection(
    YAML.load(ERB.new(File.read("config/database.yml")).result)[ENV['RACK_ENV']]
  )

  # outpt logs
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Migrator.migrate(MIGRATIONS_DIR, ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
  end

  desc 'Roll back the database schema to the previous version'
  task :rollback do
    ActiveRecord::Migrator.rollback(MIGRATIONS_DIR, ENV['STEP'] ? ENV['STEP'].to_i : 1)
  end
end

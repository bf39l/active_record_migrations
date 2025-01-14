require "active_record_migrations/version"
require 'active_record'
require 'active_record/tasks/database_tasks'
require 'rails'
require 'rails/application'
require 'active_record_migrations/configurations'

# those requires are missing from AR but are required:
require 'zlib'
require 'digest'

module ActiveRecordMigrations
  include ActiveRecord::Tasks

  def self.configure(&block)
    create_rails_app_if_not_exists
    configurations.configure &block
  end

  def self.load_tasks
    create_rails_app_if_not_exists

    load 'active_record/railties/databases.rake'
    load 'active_record_migrations/tasks/new_migration.rake'

    ActiveRecord::Base.schema_format = configurations.schema_format
    DatabaseTasks.env = configurations.environment
    Rails.env = DatabaseTasks.env
    DatabaseTasks.seed_loader = configurations.seed_loader
    ActiveRecord::Base.configurations = DatabaseTasks.database_configuration =
      configurations.database_configuration
    ActiveRecord::Base.establish_connection ActiveRecord::Tasks::DatabaseTasks.env.to_sym
    DatabaseTasks.db_dir = configurations.db_dir
    DatabaseTasks.migrations_paths = configurations.migrations_paths
    DatabaseTasks.root = Rails.root
  end

  private

  def self.create_rails_app_if_not_exists
    Class.new(Rails::Application) unless Rails.application
  end

  def self.configurations
    Configurations.instance
  end
end


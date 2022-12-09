require 'active_record'
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

BOT_CONFIG = YAML.load_file 'config/config.yml'

namespace :db do
  chatgpt = BOT_CONFIG['db']

  desc 'Create the database'
  task :create do
    ActiveRecord::Base.establish_connection(chatgpt)
    puts 'Database created.'
  end

  desc 'Migrate the database'
  task :migrate do
    ActiveRecord::Base.establish_connection(chatgpt)
    ActiveRecord::Tasks::DatabaseTasks.migrate
    # ActiveRecord::Migrator.migrate('db/migrate/')
    puts 'Database migrated.'
  end

  desc 'Rollback the database'
  task :rollback do
    step = ENV['STEP'] ? ENV['STEP'].to_i : 1
    ActiveRecord::Base.establish_connection(chatgpt)
    ActiveRecord::Base.connection.migration_context.rollback(step)
    puts 'Database rollback success.'
  end

  desc 'Drop the database'
  task :drop do
    system 'rm db/chatgpt.sqlite3'
    puts 'Database deleted.'
  end
end

namespace :g do
  desc 'Generate migration'
  task :migration do
    name = ARGV[1] || raise('Specify name: rake g:migration your_migration')
    timestamp = Time.now.strftime('%Y%m%d%H%M%S')
    path = File.expand_path("../db/migrate/#{timestamp}_#{name}.rb", __FILE__)
    migration_class = name.split('_').map(&:capitalize).join

    File.open(path, 'w') do |file|
      file.write <<~EOF
        class #{migration_class} < ActiveRecord::Migration[6.1]
          def change
          end
        end
      EOF
    end
    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end

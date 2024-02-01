# Rakefile

namespace :db do
  def current_database_config
    App.config.database_config
  end

  task :environment do
    require_relative './config/environment'
    App.load_current_environment!
    App.load_initializers!
  end

  task create: [:environment] do
    database_config = current_database_config
    # Duping the settings to connect to postgres database
    # This is to avoid connecting to the default environment database, which
    # will fail since it is not yet created.
    postgres_settings = database_config.dup.tap do |conf|
      conf.database = 'postgres'
    end
    DatabaseConnection.establish!(database_config: postgres_settings)

    database_name = database_config.database

    if DatabaseConnection.database_exists?(database_name)
      puts 'Database already exists'
    else
      DatabaseConnection.create_database!(database_name)
    end
  end

  task migrate: [:environment] do
    database_config = current_database_config
    DatabaseConnection.establish!
    database_url = DatabaseConnection.database_url
    migrations_path = DatabaseConnection.migrations_path
    schema_file_path = DatabaseConnection.schema_file_path

    migration_command = "bin/sequel -m #{migrations_path} #{database_url}"
    schema_dump_command = "bin/sequel -d #{database_url}"

    # TODO: Handle errors
    puts "Running #{migration_command}"
    `#{migration_command}`
    puts "Dumping the schema"

    next if App.development_environment?
    # TODO: Handle errors
    schema_output = `#{schema_dump_command}`
    schema_file_path.write(schema_output)
  end

  desc "generates a migration file with a timestamp and name"
  task :generate_migration, [:name] => [:environment] do |_, args|
    args.with_defaults(name: 'migration')

    migration_template = <<~MIGRATION
      Sequel.migration do
        up do
        end

        down do
        end
      end
    MIGRATION
    migrations_path = DatabaseConnection.migrations_path

    file_name = "#{Time.now.strftime('%Y%m%d%H%M%S')}_#{args.name}.rb"
    FileUtils.mkdir_p(migrations_path)

    File.open(File.join(migrations_path, file_name), 'w') do |file|
      file.write(migration_template)
    end
  end
end

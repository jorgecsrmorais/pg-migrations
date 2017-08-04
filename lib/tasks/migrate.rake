require 'pg'

namespace :pg do
  namespace :migrations do

    desc 'Setup the (pg) database for migrations'
    task :setup do
      pg_connection = get_pg_connection()
      begin
        pg_connection.exec %Q[
          CREATE TABLE IF NOT EXISTS schema_migrations (
            version character varying(255) NOT NULL UNIQUE
          )
        ]
      rescue Exception => e
        raise e
      ensure
        pg_connection.close()
      end
    end

    desc 'Migrate the (pg) database'
    task :migrate do

      pg_connection = get_pg_connection()
      begin
        Dir.glob('db/migrate/*.rb').each do |migration_file|
          version, class_name = get_migration_info(migration_file)
          next if version.nil?
          next if migration_ran?(pg_connection, version)
          run pg_connection, version, class_name, migration_file
        end
      rescue Exception => e
        raise e
      ensure
        pg_connection.close()
      end

    end

    desc 'Rollback the last migration from the (pg) database'
    task :rollback do

      pg_connection = get_pg_connection()
      begin
        last_migration_version = get_last_migration_version(pg_connection)
        if !last_migration_version.blank?
          last_migration_file = Dir.glob("db/migrate/#{last_migration_version}*.rb").first
          if last_migration_file
            version, class_name = get_migration_info(last_migration_file)
            run pg_connection, version, class_name, last_migration_file, :down
          else
            # TODO: raise exception
          end
        else
          get_logger().debug "Done, nothing to rollback."
        end
      rescue Exception => e
        raise e
      ensure
        pg_connection.close()
      end

    end

  end
end

private

  def get_logger
    return Rails.logger || Logger.new(STDOUT) if defined?(Rails)
    return Logger.new(STDOUT)
  end

  def get_pg_connection
    config_database_file = File.join('config', 'database.yml')
    if File.exist?(config_database_file)
      config = YAML.load_file(config_database_file)[ENV['RAILS_ENV'] || 'development']
      if config['adapter'] == 'postgresql'
        pg_connection = PG.connect(
          host: config['host'],
          port: config['port'],
          dbname: config['database'],
          user: config['username'],
          password: config['password'],
          connect_timeout: config['timeout']
        )
        pg_connection
      else
        # TODO: raise exception
      end
    else
      # TODO: raise exception
    end
  end

  def get_last_migration_version(connection)
    result = connection.exec %Q[
      SELECT version FROM schema_migrations
      ORDER BY version DESC
      LIMIT 1
    ]
    result = result.map { |r| r['version'] }
    result.first
  end

  def migration_ran?(connection, version)
    result = connection.exec %Q[
      SELECT version FROM schema_migrations
      WHERE version = '#{version}'
    ]
    result.to_a.length > 0
  end

  def get_migration_info(migration_file)
    filename = File.basename(migration_file, '.rb')
    file_info = /^(?<version>(\d){14})_(?<class>(\w|_)*)$/.match(filename)
    return [ file_info[:version].to_s, file_info[:class].to_s.camelize ] if file_info
    [ nil, nil ]
  end

  def run(connection, version, class_name, class_file, direction = :up)
    _log = get_logger()
    _log.debug green("#{direction.to_sym == :up ? 'Running' : 'Rolling back'} migration #{class_name} (#{version})...")
    load class_file
    migration_class = class_name.constantize
    return if !(migration_class < Pg::Migrations::Migration)
    migration = migration_class.new(connection, version)
    migration.send "_#{direction}"
    _log.debug green("Done.")
  end

  def bold(t) ; "\033[1m#{t}\033[0m" ; end
  def red(t) ; "\e[31m#{t}\e[0m" ; end
  def green(t) ; "\e[32m#{t}\e[0m" ; end
  def gray(t) ; "\e[37m#{t}\e[0m" ; end

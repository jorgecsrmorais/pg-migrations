# Pg::Migrations

This gem was built for those (like me) that don't want to use ActiveRecord and its overhead to handle model data retrieval and persistence but do like ActiveRecord's handling of database migrations.

The gem implements a simple no-fuss handling of database migrations in Postgres, using only the `pg` gem but allowing versioning, migrating and rolling back in a way similar to ActiveRecord's.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg-migrations'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg-migrations

## Usage

The gem connects to a Postgres database using the configuration in `config/database.yml` for the environment set in `RAILS_ENV` (same as ActiveRecord).

Schema versioning is implemented, as in ActiveRecord, through a `schema_migrations` table in the database. This table can be created executing:

    $ rake pg:migrations:setup

Again like ActiveRecord, the migration classes are defined in timestamped Ruby files in the `db/migrate` folder in the app. The filename MUST begin with a 14-digit timestamp (YYYYMMDDHHMMSS) followed by underscore and the class name in snake case.

The migration classes MUST inherit from `Pg::Migrations::Migration` and implement `up` and `down` methods (no support for `change`, obviously). These methods should execute the Postgres-SQL queries required for migrating and rolling back using the `execute` method. For example:

```ruby
# In the file `db/migrate/20170101000000_example_migration.rb`:

class ExampleMigration < Pg::Migrations::Migration

  def up
    execute %q[ ... Postgres-SQL query(ies) for migrating up ]
  end

  def down
    execute %q[ ... Postgres-SQL query(ies) for rolling back ]
  end

end
```

All `execute` calls inside `up` or `down` run inside a transaction, and will be rolled back if an exception is raised.

Migrating and rolling back is done executing

    $ rake pg:migrations:migrate

and

    $ rake pg:migrations:rollback

respectively.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jorgecsrmorais/pg-migrations.

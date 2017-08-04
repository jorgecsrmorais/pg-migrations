# When using the gem from a Rails app, make the gem's tasks available in the app

module Pg
  module Migrations
    class Railtie < Rails::Railtie
      rake_tasks do
        load 'tasks/migrate.rake'
      end
    end
  end
end
module Pg
  module Migrations

    class Migration

      def initialize(connection, version) ; @connection = connection ; @version = version ; end
      def up ; ; end
      def down ; ; end

      protected

        def execute(query)
          @_c.exec(query)
        end

      private

        def _up ; run_inside_transaction { up() ; add_version() } ; end
        def _down ; run_inside_transaction { down() ; remove_version() } ; end

        def run_inside_transaction
          @connection.transaction do |c|
            @_c = c
            yield
            @_c = nil
          end
        end

        def add_version
          @_c.exec %Q[
            INSERT INTO schema_migrations (version) VALUES ('#{@version}')
          ]
        end

        def remove_version
          @_c.exec %Q[
            DELETE FROM schema_migrations
            WHERE version = '#{@version}'
          ]
        end

    end

  end
end

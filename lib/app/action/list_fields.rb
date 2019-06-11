module App
  module Action
    class ListFields

      def initialize(cli)
        @cli = cli
      end

      def run
        list_searchable_fields
      end

      private

      def list_searchable_fields
        indexed_fields = Database::Database.instance.all_indexed_fields
        indexed_fields.each do |table_name, fields|
          @cli.say "Search #{table_name} with:"
          fields.each { |field| @cli.say field }
          @cli.say "\n--------------------------"
        end
      end

    end
  end
end
require 'tty-pager'


module App
  module Action
    class ListFields

      def initialize(cli)
        @cli = cli
        @pager = TTY::Pager.new
        @pastel = Pastel.new
      end

      def run
        list_searchable_fields
      end

      private

      def list_searchable_fields
        indexed_fields = Database::Database.instance.all_indexed_fields
        output = indexed_fields.map do |table_name, fields|
          @pastel.bold("Search #{table_name} with:\n") + fields.join("\n")
        end

        @pager.page(output.join("\n-------------------------------------------------------\n"))
      end

    end
  end
end
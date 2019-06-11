require 'tty-pager'
require 'tty-table'
require_relative '../../helpers/input_helper'

module App
  module Action
    class SearchDatabase

      include Helper::InputHelper

      def initialize(cli)
        @cli = cli
        @pager = TTY::Pager.new
        @pastel = Pastel.new
      end

      def run
        search_entity_prompt
      end

      private

      def search_entity_prompt
        @cli.choose do |menu|
          menu.prompt = "What whould you like to search on"
          menu.choice('User') { |search_type| search_term_prompt(search_type) }
          menu.choice('Ticket') { |search_type| search_term_prompt(search_type) }
          menu.choice('Organization') { |search_type| search_term_prompt(search_type) }
        end
      end

      def search_term_prompt(table_name)
        valid_search_fields = Database::Database.instance.search_fields_for(table_name).join(', ')

        search_term = @cli.ask("Enter search term") do |search_term|
          search_term.validate              = ->(term) { Database::Database.instance.can_search_on?(table_name, term) }
          search_term.responses[:not_valid] = "Search field must be one of #{valid_search_fields}"
        end

        search_value_prompt(table_name, search_term)
      end

      def search_value_prompt(table_name, search_term)
        search_value = @cli.ask("Enter search value")

        search_value = format_for_searching(search_value)

        results = Database::Database.instance.find(table_name, search_term, search_value)

        render_search_results(results, table_name, search_term, search_value)
      end

      def render_search_results(results, table_name, search_term, search_value)
        if results.empty?
          @cli.say "No #{table_name} found with #{search_term} of value #{search_value}"
        else
          output = results.map do |result|
            view_class = Object.const_get("Views::#{table_name}")
            table = TTY::Table.new header: [@pastel.bold('Field Name'), @pastel.bold('Value')],
                                   rows: view_class.format(result)
            table.render(:basic, multiline: true)
          end

          output << @pastel.cyan("Returned #{results.count} entries of type #{table_name}")

          @pager.page(output.join("\n-------------------------------------------------------\n"))
        end
      end
    end
  end
end
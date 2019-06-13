require 'tty-pager'
require 'tty-prompt'
require 'tty-table'
require_relative '../../helpers/input_helper'

module App
  module Action
    class SearchDatabase

      include Helper::InputHelper

      def initialize(cli)
        @cli = cli
        @pager = TTY::Pager::BasicPager.new
        @pastel = Pastel.new
      end

      def run
        search_entity_prompt
      end

      private

      def search_entity_prompt

        table_names = Database::Database.instance.table_names

        prompt = TTY::Prompt.new
        search_type = prompt.select('What would you like to search on?', table_names,
                                    { filter: true })

        search_term_prompt(search_type)
      end

      def search_term_prompt(table_name)
        search_fields = Database::Database.instance.search_fields_for(table_name)

        prompt = TTY::Prompt.new
        search_term = prompt.select('Choose the field to search against', search_fields,
                                    { filter: true })

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
            @found_search_term = false
            view_class = Object.const_get("Views::#{table_name}")
            table = TTY::Table.new header: [@pastel.bold('Field Name'), @pastel.bold('Value')],
                                   rows: view_class.format(result)

            table.render(:basic, multiline: true, column_widths: [20, 60]) do |renderer|
              renderer.filter = filter_search_result(search_term, search_value.to_s)
            end
          end

          output << @pastel.cyan("Returned #{results.count} entries of type #{table_name}")

          @pager.page(output.join("\n-------------------------------------------------------\n"))
        end
      end

      def filter_search_result(search_term, search_value)
        Proc.new do |value, row_index, col_index|
          if row_index > 0 # Row 0 is header row
            if col_index == 0 # The search field
              if value.strip == search_term
                @found_search_term = true
                @pastel.black.on_green(value)
              else
                value
              end
            else #col_index == 1 - The search
              if @found_search_term
                @found_search_term = false
                split_vals = value.split("\n")
                return_values = split_vals.map { |val| val.strip == search_value ? @pastel.black.on_green(val) : val }
                return_values.join("\n")
              else
                value
              end
            end
          else
            value
          end
        end
      end
    end
  end
end
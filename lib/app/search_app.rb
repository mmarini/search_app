require 'highline'
require 'tty-table'
require_relative '../helpers/input_helper'

module App
  class SearchApp

    include Helper::InputHelper

    ORGANIZATION_DATA = File.dirname(__FILE__) + '/../../data/organizations.json'
    TICKET_DATA = File.dirname(__FILE__) + '/../../data/tickets.json'
    USER_DATA = File.dirname(__FILE__) + '/../../data/users.json'

    def run
      @cli = HighLine.new

      pre_start

      loop do
        @cli.say "\n"
        main_menu
      end
    end

    private

    def pre_start
      @cli.say "Loading Organizations..."
      table = load_data(ORGANIZATION_DATA, Models::Organization)
      @cli.say "Loaded #{table.count} Organizations"

      @cli.say "Loading Tickets..."
      table = load_data(TICKET_DATA, Models::Ticket)
      @cli.say "Loaded #{table.count} Tickets"

      @cli.say "Loading Users..."
      table = load_data(USER_DATA, Models::User)
      @cli.say "Loaded #{table.count} Users"
    end

    def load_data(file_path, klass)
      table = Database::Database.instance.add_table(klass.name.split('::').last)
      Importer::JSONImporter.import(file_path, klass) do |entry|
        table.add_entry(entry)
      end
    end

    def main_menu
      @cli.say "Welcome to the Zendesk search app"

      @cli.choose do |menu|
        menu.prompt = "Please select an option"
        menu.choice('Search Zendesk') { search_entity_prompt }
        menu.choice('List Searchable Fields') { list_searchable_fields }
        menu.choice('Quit') { exit }
      end
    end

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
        results.each do |result|
          view_class = Object.const_get("Views::#{table_name}")
          table = TTY::Table.new header: ['Field Name', 'Value'], rows: view_class.format(result)
          @cli.say table.render(:basic, multiline: true)
          @cli.say "\n--------------------------"
        end

        @cli.say "Returned #{results.count} entries of type #{table_name}"
      end
    end

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
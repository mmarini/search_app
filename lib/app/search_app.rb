require 'highline'
require 'tty-table'

module App
  class SearchApp

    ORGANIZATION_DATA = File.dirname(__FILE__) + '/../../data/organizations.json'
    TICKET_DATA = File.dirname(__FILE__) + '/../../data/tickets.json'
    USER_DATA = File.dirname(__FILE__) + '/../../data/users.json'

    def initialize
      @cli = HighLine.new
      @search_database = App::Action::SearchDatabase.new(@cli)
      @list_fields = App::Action::ListFields.new(@cli)
      initialize_database
    end

    def run
      loop do
        main_menu
      end
    end

    private

    def initialize_database
      @cli.say 'Loading Organizations...'
      table = load_data(ORGANIZATION_DATA, Models::Organization)
      @cli.say "Loaded #{table.count} Organizations"

      @cli.say 'Loading Tickets...'
      table = load_data(TICKET_DATA, Models::Ticket)
      @cli.say "Loaded #{table.count} Tickets"

      @cli.say 'Loading Users...'
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
      @cli.say "\nWelcome to the Zendesk search app"

      @cli.choose do |menu|
        menu.prompt = 'Please select an option'
        menu.choice('Search Zendesk') { @search_database.run }
        menu.choice('List Searchable Fields') { @list_fields.run }
        menu.choice('Quit') { exit }
      end
    end
  end
end
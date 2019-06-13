require 'highline'

require 'tty-spinner'

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
      load_table(ORGANIZATION_DATA, Models::Organization)
      load_table(TICKET_DATA, Models::Ticket)
      load_table(USER_DATA, Models::User)
    end

    def load_table(data_path, klass)
      name = klass.name.split('::').last
      spinner = TTY::Spinner.new("[:spinner] Loading #{name}")
      table = load_data(data_path, klass)
      spinner.success("(Loaded #{table.count} records)")
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
        menu.choice('Quit') { exit_app }
      end
    end

    def exit_app
      @cli.say("Bye")
      exit
    end
  end
end
require 'highline'

class SearchApp

  ORGANIZATION_DATA = File.dirname(__FILE__) + '/../../data/organizations.json'
  TICKET_DATA = File.dirname(__FILE__) + '/../../data/tickets.json'
  USER_DATA = File.dirname(__FILE__) + '/../../data/users.json'

  def self.run
    @cli = HighLine.new

    pre_start
    main_menu
  end

  private

  def self.pre_start
    @cli.say "Loading Organizations..."
    table = load_data(ORGANIZATION_DATA, Organization)
    @cli.say "Loaded #{table.count} Organizations"

    @cli.say "Loading Tickets..."
    table = load_data(TICKET_DATA, Ticket)
    @cli.say "Loaded #{table.count} Tickets"

    @cli.say "Loading Users..."
    table = load_data(USER_DATA, User)
    @cli.say "Loaded #{table.count} Users"
  end

  def self.load_data(file_path, klass)
    table = Database.instance.add_table(klass.name)
    Importer.import(file_path, klass) do |organization|
      table.add_entry(organization)
    end
  end

  def self.main_menu
    @cli.say "Welcome to the search app"

    @cli.choose do |menu|
      menu.prompt = "Please select an option"
      menu.choice('Search Zendesk') { search_entity_prompt }
      menu.choice('Quit') { @cli.say("exiting") }
    end
  end

  def self.search_entity_prompt
    @cli.choose do |menu|
      menu.prompt = "What whould you like to search on"
      menu.choice('User') { |search_type| search_term_prompt(search_type) }
      menu.choice('Ticket') { |search_type| search_term_prompt(search_type) }
      menu.choice('Organization') { |search_type| search_term_prompt(search_type) }
    end
  end

  def self.search_term_prompt(table_name)
    valid_search_fields = Database.instance.search_fields_for(table_name).join(', ')

    search_term = @cli.ask("Enter search term") do |search_term|
      search_term.validate              = ->(term) { Database.instance.can_search_on?(table_name, term) }
      search_term.responses[:not_valid] = "Search field must be one of #{valid_search_fields}"
    end

    search_value_prompt(table_name, search_term)
  end

  def self.search_value_prompt(table_name, search_term)
    search_value = @cli.ask("Enter search value")

    search_value = search_value.to_i if search_value.match?(/^\d+$/)

    results = Database.instance.find(table_name, search_term, search_value)

    puts results
  end

end
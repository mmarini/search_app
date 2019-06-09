require 'helpers/validators'

class Database

  include Validators

  attr_reader :name

  def initialize(name)
    @name = validate_string_presence(name, 'name')

    @tables = {}
  end

  def add_table(name)
    table_name = validate_string_presence(name, 'name')
    raise StandardError.new("table name #{table_name} already exists") if @tables.has_key?(table_name)

    table = Table.new(table_name)
    @tables[name] = table
    table
  end

  def find(table_name, field, value)
    table = @tables[table_name]
    return [] if table.nil?
    table.find(field, value)
  end

end
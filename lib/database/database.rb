require_relative '../helpers/validators'
require 'singleton'

class Database

  include Singleton
  include Validators

  def initialize()
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

  def can_search_on?(table_name, field)
    table = @tables[table_name]
    return false if table.nil?
    table.can_search_on?(field)
  end

  def search_fields_for(table_name)
    table = @tables[table_name]
    return [] if table.nil?

    table.indexed_fields
  end

end
require_relative '../helpers/validators'

class Table

  include Validators

  attr_reader :name

  def initialize(name)
    @name = validate_string_presence(name, 'name')

    @entries = []
    @indexes = {}
  end

  def add_entry(entry)
    raise StandardError.new('entry cannot be nil') if entry.nil?
    @entries << entry
    index_entry(entry, @entries.length - 1)
    entry
  end

  def count
    @entries.count
  end

  def find(field, value)
    index = @indexes[field]
    return [] if index.nil?
    positions = index.find_value(value)
    positions.map { |pos| @entries[pos] }
  end

  def can_search_on?(field)
    @indexes.has_key?(field)
  end

  def indexed_fields
    @indexes.keys
  end

  private

  def index_entry(entry, position)
    entry.indexable_fields.each do |field_name|
      index = get_or_create_index(field_name)
      index.index_value(entry.instance_variable_get("@#{field_name}"), position)
    end
  end

  def get_or_create_index(field)
    index = @indexes[field]
    if index.nil?
      index = Index.new(field)
      @indexes[field] = index
    end

    index
  end

  def format_field_name(name)

  end

end
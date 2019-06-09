require 'helpers/validators'

class Index

  include Validators

  attr_reader :name

  def initialize(name)
    @name = validate_string_presence(name, 'name')

    @index = {}
  end

  def index_value(value, position)
    index = get_or_create_index(value)
    index.add(position)

    position
  end

  def find_value(value)
    index = @index[value]
    return [] if index.nil?

    index
  end

  private

  def get_or_create_index(value)
    index = @index[value]
    if index.nil?
      index = Set.new
      @index[value] = index
    end

    index
  end


end
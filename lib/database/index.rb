require_relative '../helpers/validators'
require 'set'

module Database
  class Index

    include Helper::Validators

    attr_reader :name

    def initialize(name)
      @name = validate_string_presence(name, 'name')

      @index = {}
    end

    def index_value(value, position)
      if value.is_a?(Array)
        value.each { |individual_value| add_to_index(individual_value, position) }
      else
        add_to_index(value, position)
      end

      position
    end

    def find_value(value)
      index = @index[value]
      return [] if index.nil?

      index
    end

    private

    def add_to_index(value, position)
      index = get_or_create_index(value)
      index.add(position)
    end

    def get_or_create_index(value)
      index = @index[value]
      if index.nil?
        index = Set.new
        @index[value] = index
      end

      index
    end
  end
end
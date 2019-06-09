require 'helpers/string_helper'

module ActiveProperties

  include StringHelper

  attr_accessor :props, :associated_entities

  def has_properties *args
    args = [primary_key.to_sym] + args
    @props = args
    instance_eval { attr_reader *args }
  end

  def has_many(name, table_name, associated_key=nil)
    define_method(name.to_s) do
      find_by(table_name, default_has_many_key(associated_key), instance_variable_get("@#{primary_key}"))
    end
  end

  def belongs_to(name, table_name, associated_key=nil)
    define_method(name.to_s) do
      result = find_by(table_name, primary_key, default_belongs_to_value(table_name, associated_key))
      result.empty? ? nil : result.first
    end
  end

  def self.included base
    base.extend self
  end

  def initialize(args)
    args.each {|key, value|
      instance_variable_set "@#{key}", value if self.class.props.member?(key.to_sym)
    } if args.is_a? Hash
  end

  def indexable_fields
    self.class.props.map { |key| key.to_s }
  end

  private

  def primary_key
    '_id'
  end

  def default_has_many_key(default_key)
    return default_key.to_s unless default_key.nil?
    underscore(self.class.name) + '_id'
  end

  def default_belongs_to_value(table_name, default_key)
    key = default_key.nil? ? underscore(table_name) + '_id' : default_key
    instance_variable_get("@#{key}")
  end

  def find_by(table_name, associated_key, id)
    database = Database.instance
    database.find(table_name, associated_key, id)
  end

end
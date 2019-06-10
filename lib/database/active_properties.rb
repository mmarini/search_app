require 'helpers/string_helper'

module ActiveProperties

  include StringHelper

  attr_accessor :props

  # has_properties takes in an array of symbols and uses it create attr_reader from them
  # The _id field is added by default
  def has_properties *args
    args = [primary_key.to_sym] + args
    @props = args
    instance_eval { attr_reader *args }
  end

  # has_many creates a method with the name of name, and will perform a database lookup
  # on the table_name
  # If an associated_key is passed in, it will use that for the lookup. Otherwise, it
  # will use a snake cased version of the table_name with '_id' appended to it as the
  # lookup key
  # This will return an Enumerable
  def has_many(name, table_name, associated_key=nil)
    define_method(name.to_s) do
      find_by(table_name, default_has_many_key(associated_key), instance_variable_get("@#{primary_key}"))
    end
  end

  # belongs_to creates a method with the name of name, and will perform a database lookup
  # on the table_name
  # If an associated_key is passed in, it will use that to determine the value to lookup on. Otherwise, it
  # will use a snake cased version of the table_name with '_id' appended to it as the
  # lookup key
  # This will return a specific object
  def belongs_to(name, table_name, associated_key=nil)
    define_method(name.to_s) do
      result = find_by(table_name, primary_key, default_belongs_to_value(table_name, associated_key))
      result.empty? ? nil : result.first
    end
  end

  def self.included base
    base.extend self
  end

  # initialize takes a hash and will populate properties with the values in the hash if they exist
  def initialize(args)
    args.each {|key, value|
      instance_variable_set "@#{key}", value if self.class.props.member?(key.to_sym)
    } if args.is_a? Hash
  end

  # uses the properties passed in via has_properties to produce a list of property names
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
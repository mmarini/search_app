require 'helpers/string_helper'

module ActiveProperties

  include StringHelper

  attr_accessor :props, :associated_entities

  def has_properties *args
    @props = args
    instance_eval { attr_reader *args }
  end

  def has_many(name, klass, associated_key=nil)
    define_method(name.to_s) do
      database = Database.instance
      database.find(klass.name.to_s, default_associated_key(associated_key), instance_variable_get("@#{primary_key}"))
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

  def default_associated_key(default_key)
    return default_key.to_s unless default_key.nil?
    underscore(self.class.name) + '_id'
  end

end
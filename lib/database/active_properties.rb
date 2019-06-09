module ActiveProperties
  attr_accessor :props

  def has_properties *args
    @props = args
    instance_eval { attr_reader *args }
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
end
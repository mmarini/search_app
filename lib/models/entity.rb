module Entity

  def initialize(args)
    args.each do |key, value|
      instance_variable_set("@#{key}", value) unless value.nil?
    end
  end

end
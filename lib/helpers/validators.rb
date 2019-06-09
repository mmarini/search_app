module Validators

  def validate_string_presence(string, label)
    raise StandardError.new("#{label} cannot be nil") if string.nil?
    string = string.strip
    raise StandardError.new("#{label} cannot be blank") if string == ''
    string
  end

end
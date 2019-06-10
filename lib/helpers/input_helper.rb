module InputHelper

  # format_for_searching will take user input and sanitize if for searching
  # 1. Check if the string is an integer. If so, return an integer
  # 2. Check if the string is a boolean (either true or false), if so, return true or false
  # 3. Return the string as is
  def self.format_for_searching(input)
    return input if input.nil?

    # 1. Check if the string is an integer. If so, return an integer
    return input.to_i if input.match?(/^\d+$/)

    # 2. Check if the string is a boolean (either true or false), if so, return true or false
    case input
    when 'true'
      true
    when 'false'
      false
    else
      # 3. Return the string as is
      input
    end
  end

end
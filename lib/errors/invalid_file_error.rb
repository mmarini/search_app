module Errors
  class InvalidFileError < StandardError
    def initialize(filename)
      message = "Error parsing file: #{filename}. Please ensure file format is correct"
      super(message)
    end
  end
end
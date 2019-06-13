require 'json'

module Importer
  class JSONImporter

    # Imports a file at filepath into objects of type klass
    # The format of the data file is a flat-ish json file. So each object does NOT have sub objects
    # The JSON is bookended by `[` and `]`
    # Params:
    # +filename+:: full path to the data file
    # +klass+:: class of the objects to return
    # +block+:: code to execute
    def self.import(filename, klass, &block)

      objects = []
      obj_string = ''

      File.open(filename).each do |line|

        line = line.strip

        next if line == '['

        obj_string += line
        if line.match('}')
          obj_string.sub!('},', '}')

          obj = parse_input_into_object(klass, obj_string, filename)

          yield obj unless block.nil?

          objects << obj
          obj_string = ''
        end
      end

      objects
    rescue Errno::ENOENT
      []
    end

    def self.parse_input_into_object(klass, json_string, filename)

      json = JSON.parse(json_string)
      klass.new(json)

    rescue JSON::ParserError
      raise Errors::InvalidFileError.new(filename)
    end
  end
end
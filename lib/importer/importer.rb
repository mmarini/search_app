require 'json'

class Importer

  # Imports a file at filepath into objects of type klass
  # The format of the data file is a flat-ish json file. So each object does NOT have sub objects
  # The JSON is bookended by `[` and `]`
  # Params:
  # +filename+:: full path to the data file
  # +klass+:: class of the objects to return
  def self.import(filename, klass)

    objects = []
    obj_string = ''

    File.open(filename).each do |line|

      line = line.strip

      next if line == '['

      obj_string += line
      if line.match('}')
        obj_string.sub!('},', '}')

        objects << klass.new(JSON.parse(obj_string))
        obj_string = ''
      end

    end

    objects
  end

end
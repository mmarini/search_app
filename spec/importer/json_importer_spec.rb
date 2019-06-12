require 'spec_helper'

class FakeClass
  include Database::ActiveProperties

  has_properties :_id, :created_at, :type, :submitter_id, :tags, :has_incidents
end

describe Importer::JSONImporter do

  describe '#import' do
    it 'imports the file into objects of the class passed in' do
      returned_data = described_class.import(File.dirname(__FILE__) + '/../data/test_data.json', FakeClass)
      expect(returned_data.size).to eq 3

      data = returned_data[0]
      expect(data).to be_an_instance_of(FakeClass)
      expect(data._id).to eql('436bf9b0-1147-4c0a-8439-6f79833bff5b')
      expect(data.created_at).to eql('2016-04-28T11:19:34 -10:00')
      expect(data.type).to eql('incident')
      expect(data.submitter_id).to eql(38)
      expect(data.tags).to eql([
                                   "Ohio",
                                   "Pennsylvania",
                                   "American Samoa",
                                   "Northern Mariana Islands"
                               ])
      expect(data.has_incidents).to be false
    end

    it 'yields to the block if passed in' do
      expect { |b| described_class.import(File.dirname(__FILE__) + '/../data/test_data.json', FakeClass, &b) }.to yield_control
    end

    it 'raises a invalid file error if the file is malformed' do
      filename = File.dirname(__FILE__) + '/../data/invalid_test_data.json'
      expect { described_class.import(filename, FakeClass) }.to raise_error(Errors::InvalidFileError)
    end

    it 'returns an empty array if file is not found' do
      filename = File.dirname(__FILE__) + '/../data/random_file_that_does_not_exist.json'
      expect(described_class.import(filename, FakeClass)).to be_empty
    end
  end

end
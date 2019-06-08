require 'spec_helper'

class FakeClass
  include Entity

  attr_reader :_id, :created_at, :type, :submitter_id, :tags, :has_incidents
end

describe Importer do

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
  end

end
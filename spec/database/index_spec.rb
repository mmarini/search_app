require 'spec_helper'

class FakeIndexEntity
  include Database::ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c, :attr_d

end

describe Database::Index do

  let(:subject) { described_class.new("test index") }

  context 'attributes' do
    it { should respond_to :name }
  end

  describe '.initialize' do
    it 'raises an error if name is nil' do
      expect{ described_class.new(nil) }.to raise_error(StandardError, 'name cannot be nil')
    end

    it 'raises an error if name is blank' do
      expect{ described_class.new('  ') }.to raise_error(StandardError, 'name cannot be blank')
    end
  end

  describe '.index_value' do
    it 'indexes the attributes of an entry' do
      entry = FakeIndexEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'})
      position = subject.index_value(entry.attr_a, 1)
      expect(position).to eq 1
      positions = subject.find_value('1')
      expect(positions).to include(1)
    end

    it 'indexes an array value' do
      entry = FakeIndexEntity.new({attr_a: ['a', 'b', 'c'], attr_b: 2, attr_c: 'abc'})
      position = subject.index_value(entry.attr_a, 1)
      expect(position).to eq 1
      ['a', 'b', 'c'].each do |value|
        positions = subject.find_value(value)
        expect(positions).to include(1)
      end
    end

    it 'indexes a blank value' do
      entry = FakeIndexEntity.new({attr_a: ['a', 'b', 'c'], attr_b: 2, attr_c: 'abc', attr_d: ''})
      position = subject.index_value(entry.attr_d, 1)
      expect(position).to eq 1

      positions = subject.find_value('')
      expect(positions).to include(1)
    end

    it 'indexes a blank value' do
      entry = FakeIndexEntity.new({attr_a: ['a', 'b', 'c'], attr_b: 2, attr_c: 'abc', attr_d: nil})
      position = subject.index_value(entry.attr_d, 1)
      expect(position).to eq 1

      positions = subject.find_value(nil)
      expect(positions).to include(1)
    end
  end
end
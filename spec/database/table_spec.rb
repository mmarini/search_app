require 'spec_helper'

class FakeDatabaseEntity
  include ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c, :attr_d

end

describe Table do

  let(:subject) { described_class.new("test table") }

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

  describe '.add_entry' do
    it 'raises an error if entry is nil' do
      expect{ subject.add_entry(nil) }.to raise_error(StandardError, 'entry cannot be nil')
    end

    it 'adds an entry to the table' do
      expect(subject.count).to eq 0
      entry = FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'})
      subject.add_entry(entry)
      expect(subject.count).to eq 1
    end
  end

  describe '.count' do
    it 'returns the number of entries' do
      expect(subject.count).to eq 0
      subject.add_entry(FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      subject.add_entry(FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      subject.add_entry(FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      expect(subject.count).to eq 3
    end
  end

  describe '.find' do

    let(:entry_1) { FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: 'same'}) }
    let(:entry_2) { FakeDatabaseEntity.new({attr_a: 'one', attr_b: 2, attr_c: 'abc', attr_d: 'same'}) }
    let(:entry_3) { FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'ABC', attr_d: 'same'}) }

    before do
      subject.add_entry(entry_1)
      subject.add_entry(entry_2)
      subject.add_entry(entry_3)
    end

    it 'returns entry_1 only' do
      results = subject.find('attr_b', 'two')
      expect(results).to include(entry_1)
      expect(results).to_not include(entry_2)
      expect(results).to_not include(entry_3)
    end

    it 'returns entry_2 only' do
      results = subject.find('attr_a', 'one')
      expect(results).to_not include(entry_1)
      expect(results).to include(entry_2)
      expect(results).to_not include(entry_3)
    end

    it 'returns entry_3 only' do
      results = subject.find('attr_c', 'ABC')
      expect(results).to_not include(entry_1)
      expect(results).to_not include(entry_2)
      expect(results).to include(entry_3)
    end

    it 'returns all entries' do
      results = subject.find('attr_d', 'same')
      expect(results).to include(entry_1)
      expect(results).to include(entry_2)
      expect(results).to include(entry_3)
    end

    it 'returns an empty list if field unknonw' do
      results = subject.find('attr_e', 'same')
      expect(results).to be_empty
    end
  end


end
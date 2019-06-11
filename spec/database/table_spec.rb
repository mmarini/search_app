require 'spec_helper'

class FakeTableEntity
  include Database::ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c, :attr_d, :attr_e

end

describe Database::Table do

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
      entry = FakeTableEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'})
      subject.add_entry(entry)
      expect(subject.count).to eq 1
    end
  end

  describe '.count' do
    it 'returns the number of entries' do
      expect(subject.count).to eq 0
      subject.add_entry(FakeTableEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      subject.add_entry(FakeTableEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      subject.add_entry(FakeTableEntity.new({attr_a: '1', attr_b: 2, attr_c: 'abc'}))
      expect(subject.count).to eq 3
    end
  end

  describe '.find' do

    let(:entry_1) { FakeTableEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: ['x', 'y', 'z'], attr_e: 'same'}) }
    let(:entry_2) { FakeTableEntity.new({attr_a: 'one', attr_b: 2, attr_c: 'abc', attr_d: ['y', 'z', 'a'], attr_e: 'same'}) }
    let(:entry_3) { FakeTableEntity.new({attr_a: '1', attr_b: 2, attr_c: 'ABC', attr_d: ['z', 'a', 'b'], attr_e: 'same'}) }

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

    context 'arrays' do

      it 'finds in arrays' do
        results = subject.find('attr_d', 'x')
        expect(results).to include(entry_1)
        expect(results).to_not include(entry_2)
        expect(results).to_not include(entry_3)
      end

      it 'finds multiple in arrays' do
        results = subject.find('attr_d', 'y')
        expect(results).to include(entry_1)
        expect(results).to include(entry_2)
        expect(results).to_not include(entry_3)
      end

      it 'finds all in arrays' do
        results = subject.find('attr_d', 'z')
        expect(results).to include(entry_1)
        expect(results).to include(entry_2)
        expect(results).to include(entry_3)
      end

    end

    it 'returns all entries' do
      results = subject.find('attr_e', 'same')
      expect(results).to include(entry_1)
      expect(results).to include(entry_2)
      expect(results).to include(entry_3)
    end

    it 'returns an empty list if field unknown' do
      results = subject.find('attr_f', 'same')
      expect(results).to be_empty
    end
  end

  describe '.can_search_on?' do

    let(:entry_1) { FakeTableEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: ['x', 'y', 'z'], attr_e: 'same'}) }

    before do
      subject.add_entry(entry_1)
    end

    it 'returns true if I can search on a specific field' do
      expect(subject.can_search_on?('attr_c')).to be_truthy
    end

    it 'returns false if the specific field does not exist' do
      expect(subject.can_search_on?('an_invalid_field')).to be_falsey
    end
  end

  describe '.indexed_fields' do

    let(:entry_1) { FakeTableEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: ['x', 'y', 'z'], attr_e: 'same'}) }

    before do
      subject.add_entry(entry_1)
    end

    it 'returns the indexed fields' do
      fields = subject.indexed_fields
      expect(fields.count).to eq 6
      expect(fields).to include('_id')
      expect(fields).to include('attr_a')
      expect(fields).to include('attr_b')
      expect(fields).to include('attr_c')
      expect(fields).to include('attr_d')
      expect(fields).to include('attr_e')
    end
  end
end
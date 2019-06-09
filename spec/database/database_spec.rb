require 'spec_helper'

describe Database do

  let(:subject) { described_class.new("test database") }

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

  describe '.add_table' do
    it 'raises an error if name is nil' do
      expect{ subject.add_table(nil) }.to raise_error(StandardError, 'name cannot be nil')
    end

    it 'raises an error if name is blank' do
      expect{ subject.add_table('   ') }.to raise_error(StandardError, 'name cannot be blank')
    end

    it 'raises an error if table name is taken' do
      subject.add_table('test_table')
      expect{ subject.add_table('test_table') }.to raise_error(StandardError, 'table name test_table already exists')
    end

    it 'creates a new table' do
      table = subject.add_table('test_table')
      expect(table).to be_kind_of(Table)
      expect(table.name).to eq('test_table')
    end
  end

  describe '.find' do

    let(:entry_1) { FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: 'same'}) }
    let(:entry_2) { FakeDatabaseEntity.new({attr_a: 'one', attr_b: 2, attr_c: 'abc', attr_d: 'same'}) }
    let(:entry_3) { FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'ABC', attr_d: 'same'}) }

    before do
      table = subject.add_table('FakeDatabaseEntity')
      table.add_entry(entry_1)
      table.add_entry(entry_2)
      table.add_entry(entry_3)
    end

    it 'returns an empty list if table name not known' do
      results = subject.find('AnotherTable', 'attr_a', '1')
      expect(results).to be_empty
    end

    it 'returns entry_2 only' do
      results = subject.find('FakeDatabaseEntity', 'attr_a', 'one')
      expect(results).to_not include(entry_1)
      expect(results).to include(entry_2)
      expect(results).to_not include(entry_3)
    end

  end

end
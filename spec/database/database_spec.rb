require 'spec_helper'

class FakeDatabaseEntity
  include Database::ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c
end

class AlternateDatabaseEntity
  include Database::ActiveProperties

  has_properties :attr_1, :attr_2, :attr_3
end


describe Database::Database do

  let(:subject) { described_class.instance }

  context 'is a singleton' do
    it 'only has 1 instance' do
      database_1 = described_class.instance
      expect(subject).to eql(database_1)
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
      table = subject.add_table('new_test_table')
      expect(table).to be_kind_of(Database::Table)
      expect(table.name).to eq('new_test_table')
    end
  end

  describe '.table_names' do
    it 'returns an array of table names' do
      subject.clear!
      3.times { |item| subject.add_table("test_table_#{item}") }

      table_names = subject.table_names
      3.times do |item|
        expect(table_names).to include("test_table_#{item}")
      end
    end
  end

  describe '.find' do

    before(:all) do
      @database = described_class.instance

      @entry_1 = FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: 'same'})
      @entry_2 = FakeDatabaseEntity.new({attr_a: 'one', attr_b: 2, attr_c: 'abc', attr_d: 'same'})
      @entry_3 = FakeDatabaseEntity.new({attr_a: '1', attr_b: 2, attr_c: 'ABC', attr_d: 'same'})

      table = @database.add_table('FakeDatabaseEntity')
      table.add_entry(@entry_1)
      table.add_entry(@entry_2)
      table.add_entry(@entry_3)
    end

    it 'returns an empty list if table name not known' do
      results = @database.find('AnotherTable', 'attr_a', '1')
      expect(results).to be_empty
    end

    it 'returns entry_2 only' do
      results = @database.find('FakeDatabaseEntity', 'attr_a', 'one')
      expect(results).to_not include(@entry_1)
      expect(results).to include(@entry_2)
      expect(results).to_not include(@entry_3)
    end

  end

  describe '.can_search_on?' do

    before(:all) do
      @database = described_class.instance

      @entry_1 = FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: 'same'})

      table = @database.add_table('CanSearchOnTest')
      table.add_entry(@entry_1)
    end

    it 'returns true if I can search on a specific field' do
      expect(@database.can_search_on?('CanSearchOnTest', 'attr_c')).to be_truthy
    end

    it 'returns false if the table name does not exist' do
      expect(@database.can_search_on?('AnInvalidTableName', 'attr_c')).to be_falsey
    end

    it 'returns false if the specific field does not exist' do
      expect(@database.can_search_on?('CanSearchOnTest', 'an_invalid_field')).to be_falsey
    end

  end

  describe '.search_fields_for' do

    before(:all) do
      @database = described_class.instance

      @entry_1 = FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc', attr_d: 'same'})

      table = @database.add_table('SearchFieldsTest')
      table.add_entry(@entry_1)
    end

    it 'returns a list of fields to search on' do
      search_fields = @database.search_fields_for('SearchFieldsTest')
      expect(search_fields).to include('attr_a')
      expect(search_fields).to include('attr_b')
      expect(search_fields).to include('attr_c')
      expect(search_fields).to_not include('attr_d')
    end

  end

  describe '.clear!' do
    it 'removes tables from the database' do
      database = described_class.instance
      database.clear!
      expect(database.number_of_tables).to eq 0
      database.add_table('TemporaryTable')
      expect(database.number_of_tables).to eq 1
      database.clear!
      expect(database.number_of_tables).to eq 0
    end
  end

  describe '.number_of_tables' do
    it 'returns the number of tables' do
      database = described_class.instance
      database.clear!
      expect(database.number_of_tables).to eq 0
      3.times do |num|
        database.add_table("TemporaryTable#{num}")
      end
      expect(database.number_of_tables).to eq 3
    end
  end

  describe '.all_indexed_fields' do
    it 'returns an array of tables and indexed fields' do
      database = described_class.instance
      database.clear!

      entry_1 = FakeDatabaseEntity.new({attr_a: '1', attr_b: 'two', attr_c: 'abc'})
      entry_2 = AlternateDatabaseEntity.new({attr_1: '1', attr_2: 'two', attr_3: 'abc'})

      table = database.add_table('FakeDatabaseEntity')
      table.add_entry(entry_1)

      table = database.add_table('AlternateDatabaseEntity')
      table.add_entry(entry_2)

      results = database.all_indexed_fields

      expect(results.count).to eq 2
      expect(results).to include(['FakeDatabaseEntity', ['_id', 'attr_a', 'attr_b', 'attr_c']])
      expect(results).to include(['AlternateDatabaseEntity', ['_id', 'attr_1', 'attr_2', 'attr_3']])
    end
  end
end
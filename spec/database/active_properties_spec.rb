require 'spec_helper'

class FakeRecord
  include ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c
end


class FakeRecordD
  include ActiveProperties

  has_properties :_id, :name, :different_id

end

class FakeRecordC
  include ActiveProperties

  has_properties :_id, :name, :fake_record_a_id, :fake_record_b_id

end

class FakeRecordB
  include ActiveProperties

  has_properties :_id, :name, :fake_record_a_id

  has_many :fake_record_cs, FakeRecordC

end

class FakeRecordA
  include ActiveProperties

  has_properties :_id, :name

  has_many :fake_record_bs, FakeRecordB
  has_many :fake_record_cs, FakeRecordC
  has_many :other_fake_records, FakeRecordD, :different_id

end

describe ActiveProperties do

  let(:subject) { FakeRecord.new({attr_a: 1, attr_b: 'two', attr_c: 'abc'}) }

  context 'attributes' do
    it { should respond_to :attr_a }
    it { should respond_to :attr_b }
    it { should respond_to :attr_c }
  end

  describe '.indexable_fields' do
    it 'returns the properties as a list of strings' do
      expect(subject.indexable_fields).to eq ['attr_a', 'attr_b', 'attr_c']
    end
  end

  describe 'has_many fields' do

    before(:all) do
      @homer = FakeRecordA.new({_id: 1, name: 'Homer'})
      @mr_burns = FakeRecordA.new({_id: 2, name: 'Mr Burns'})

      @marge = FakeRecordB.new({_id: 1, name: 'Marge', fake_record_a_id: 1})
      @bart = FakeRecordB.new({_id: 2, name: 'Bart', fake_record_a_id: 1})
      @moe = FakeRecordB.new({_id: 3, name: 'Moe', fake_record_a_id: 3})

      @lisa = FakeRecordC.new({_id: 1, name: 'Lisa', fake_record_a_id: 1, fake_record_b_id: 1})
      @maggie = FakeRecordC.new({_id: 2, name: 'Maggie', fake_record_a_id: 1, fake_record_b_id: 2})
      @barney = FakeRecordC.new({_id: 2, name: 'Barney', fake_record_a_id: 3, fake_record_b_id: 3})

      @smithers = FakeRecordD.new({_id: 1, name: 'Smithers', different_id: 2})

      @database = Database.instance
      table = @database.add_table(FakeRecordA.name.to_s)
      table.add_entry(@homer)
      table.add_entry(@mr_burns)

      table = @database.add_table(FakeRecordB.name.to_s)
      table.add_entry(@marge)
      table.add_entry(@bart)
      table.add_entry(@moe)

      table = @database.add_table(FakeRecordC.name.to_s)
      table.add_entry(@lisa)
      table.add_entry(@maggie)
      table.add_entry(@barney)

      table = @database.add_table(FakeRecordD.name.to_s)
      table.add_entry(@smithers)
    end

    context 'Homer' do
      it 'returns associated b records' do
        result_a = @database.find(FakeRecordA.name.to_s, '_id', 1).first
        associated_bs = result_a.fake_record_bs
        expect(associated_bs.count).to eq 2
        expect(associated_bs).to include(@marge)
        expect(associated_bs).to include(@bart)
        expect(associated_bs).to_not include(@moe)
      end

      it 'returns associated c records' do
        result_a = @database.find(FakeRecordA.name.to_s, '_id', 1).first
        associated_cs = result_a.fake_record_cs
        expect(associated_cs.count).to eq 2
        expect(associated_cs).to include(@lisa)
        expect(associated_cs).to include(@maggie)
        expect(associated_cs).to_not include(@barney)
      end
    end

    context 'Mr Burns' do
      it 'returns no associated b records' do
        result_a = @database.find(FakeRecordA.name.to_s, '_id', 2).first
        associated_bs = result_a.fake_record_bs
        expect(associated_bs.count).to eq 0
      end

      it 'returns associated c records' do
        result_a = @database.find(FakeRecordA.name.to_s, '_id', 2).first
        associated_cs = result_a.fake_record_cs
        expect(associated_cs.count).to eq 0
      end

      it 'returns associated other records' do
        result_a = @database.find(FakeRecordA.name.to_s, '_id', 2).first
        associated_other = result_a.other_fake_records
        expect(associated_other.count).to eq 1
        expect(associated_other).to include(@smithers)
      end
    end

    context 'Marge' do
      it 'returns associated c records for marge' do
        result_b = @database.find(FakeRecordB.name.to_s, '_id', 1).first
        associated_cs = result_b.fake_record_cs
        expect(associated_cs.count).to eq 1
        expect(associated_cs).to include(@lisa)
        expect(associated_cs).to_not include(@maggie)
        expect(associated_cs).to_not include(@barney)
      end
    end

  end

end
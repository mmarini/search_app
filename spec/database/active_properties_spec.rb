require 'spec_helper'

class FakeRecord
  include ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c
end

class TestParent

  include ActiveProperties

  has_properties :_id, :name

  has_many :children, 'TestChild'
  has_many :secret_children, 'TestChild', :secret_parent_id

end

class TestChild

  include ActiveProperties

  has_properties :_id, :name, :test_parent_id, :secret_parent_id

  belongs_to :parent, 'TestParent'
  belongs_to :unknown_parent, 'TestParent', :secret_parent_id

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
      expect(subject.indexable_fields).to include('_id')
      expect(subject.indexable_fields).to include('attr_a')
      expect(subject.indexable_fields).to include('attr_b')
      expect(subject.indexable_fields).to include('attr_c')
    end
  end

  context 'associations' do

    before(:all) do
      @parent_1 = TestParent.new({_id: 1, name: 'Test Parent 1'})
      @parent_2 = TestParent.new({_id: 2, name: 'Test Parent 2'})

      @child_1 = TestChild.new({_id: 1, name: 'Bart', test_parent_id: 1})
      @child_2 = TestChild.new({_id: 2, name: 'Lisa', test_parent_id: 1})
      @child_3 = TestChild.new({_id: 3, name: 'Maggie', test_parent_id: 1})

      @orphan_1 = TestChild.new({_id: 4, name: 'Timmy', test_parent_id: 100})

      @secret_child_1 = TestChild.new({_id: 5, name: 'Lenny', secret_parent_id: 1})
      @secret_child_2 = TestChild.new({_id: 6, name: 'Carl', secret_parent_id: 1})

      @database = Database.instance
      table = @database.add_table(TestParent.name.to_s)
      table.add_entry(@parent_1)
      table.add_entry(@parent_2)

      table = @database.add_table(TestChild.name.to_s)
      table.add_entry(@child_1)
      table.add_entry(@child_2)
      table.add_entry(@child_3)
      table.add_entry(@orphan_1)
      table.add_entry(@secret_child_1)
      table.add_entry(@secret_child_2)
    end


    describe 'has many' do
      it 'returns children' do
        parent = @database.find(TestParent.name.to_s, '_id', 1).first
        children = parent.children
        expect(children.count).to eq 3
        expect(children).to include(@child_1)
        expect(children).to include(@child_2)
        expect(children).to include(@child_3)
        expect(children).to_not include(@orphan_1)
      end

      it 'returns no children' do
        parent = @database.find(TestParent.name.to_s, '_id', 2).first
        children = parent.children
        expect(children.count).to eq 0
        expect(children).to be_empty
      end

      it 'retuns child via specific id' do
        parent = @database.find(TestParent.name.to_s, '_id', 1).first
        children = parent.secret_children
        expect(children.count).to eq 2
        expect(children).to include(@secret_child_1)
        expect(children).to include(@secret_child_2)
      end
    end

    describe 'belongs to' do
      it 'returns parent' do
        child = @database.find(TestChild.name.to_s, '_id', 1).first
        expect(child.parent).to eq @parent_1
      end

      it 'does not return a parent' do
        child = @database.find(TestChild.name.to_s, '_id', 4).first
        expect(child.parent).to be_nil
      end

      it 'returns parent via specific id' do
        child = @database.find(TestChild.name.to_s, '_id', 5).first
        expect(child.unknown_parent).to eq @parent_1
      end

    end
  end
end
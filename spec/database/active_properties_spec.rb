require 'spec_helper'

class FakeRecord
  include ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c
end

class FakeOrganization
  include ActiveProperties

  has_properties :_id, :name

  has_many :fake_employees, 'FakeEmployee'
  has_many :fake_underlings, 'FakeUnderling'
  has_many :other_fake_records, 'FakeHiredGoon', :different_id
end

class FakeEmployee
  include ActiveProperties

  has_properties :_id, :name, :fake_organization_id

  has_many :fake_underlings, 'FakeUnderling'

  belongs_to :fake_organization, 'FakeOrganization'
end

class FakeUnderling
  include ActiveProperties

  has_properties :_id, :name, :fake_organization_id, :fake_employee_id
end

class FakeHiredGoon
  include ActiveProperties

  has_properties :_id, :name, :different_id

  belongs_to :fake_secret_org, 'FakeOrganization', :different_id

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

  context 'associations' do

    before(:all) do
      @power_plant = FakeOrganization.new({_id: 1, name: 'Springfield PowerPlant'})
      @moes_bar = FakeOrganization.new({_id: 2, name: 'Moes Bar'})

      @homer = FakeEmployee.new({_id: 1, name: 'Homer', fake_organization_id: 1})
      @lenny = FakeEmployee.new({_id: 2, name: 'Lenny', fake_organization_id: 1})
      @frank_grimes = FakeEmployee.new({_id: 3, name: 'Frank Grimes', fake_organization_id: 3})

      @smithers = FakeUnderling.new({_id: 1, name: 'Smithers', fake_organization_id: 1, fake_employee_id: 1})
      @jeeves = FakeUnderling.new({_id: 2, name: 'Jeeves', fake_organization_id: 1, fake_employee_id: 2})
      @barney = FakeUnderling.new({_id: 3, name: 'Barney', fake_organization_id: 3, fake_employee_id: 4})

      @shorty = FakeHiredGoon.new({_id: 1, name: 'Shorty', different_id: 2})

      @database = Database.instance
      table = @database.add_table(FakeOrganization.name.to_s)
      table.add_entry(@power_plant)
      table.add_entry(@moes_bar)

      table = @database.add_table(FakeEmployee.name.to_s)
      table.add_entry(@homer)
      table.add_entry(@lenny)
      table.add_entry(@frank_grimes)

      table = @database.add_table(FakeUnderling.name.to_s)
      table.add_entry(@smithers)
      table.add_entry(@jeeves)
      table.add_entry(@barney)

      table = @database.add_table(FakeHiredGoon.name.to_s)
      table.add_entry(@shorty)
    end

    describe 'has_many fields' do

      context 'Power Plant' do
        it 'returns associated employees' do
          result_a = @database.find(FakeOrganization.name.to_s, '_id', 1).first
          fake_employees = result_a.fake_employees
          expect(fake_employees.count).to eq 2
          expect(fake_employees).to include(@homer)
          expect(fake_employees).to include(@lenny)
          expect(fake_employees).to_not include(@frank_grimes)
        end

        it 'returns associated underlings' do
          result_a = @database.find(FakeOrganization.name.to_s, '_id', 1).first
          fake_underlings = result_a.fake_underlings
          expect(fake_underlings.count).to eq 2
          expect(fake_underlings).to include(@smithers)
          expect(fake_underlings).to include(@jeeves)
          expect(fake_underlings).to_not include(@barney)
        end
      end

      context 'Moes Bar' do
        it 'returns no associated employees' do
          result_a = @database.find(FakeOrganization.name.to_s, '_id', 2).first
          fake_employees = result_a.fake_employees
          expect(fake_employees.count).to eq 0
        end

        it 'returns associated underlings' do
          result_a = @database.find(FakeOrganization.name.to_s, '_id', 2).first
          fake_underlings = result_a.fake_underlings
          expect(fake_underlings.count).to eq 0
        end

        it 'returns associated other records' do
          result_a = @database.find(FakeOrganization.name.to_s, '_id', 2).first
          associated_other = result_a.other_fake_records
          expect(associated_other.count).to eq 1
          expect(associated_other).to include(@shorty)
        end
      end

      context 'Homer' do
        it 'returns associated underlings for homer' do
          result_b = @database.find(FakeEmployee.name.to_s, '_id', 1).first
          fake_underlings = result_b.fake_underlings
          expect(fake_underlings.count).to eq 1
          expect(fake_underlings).to include(@smithers)
          expect(fake_underlings).to_not include(@jeeves)
          expect(fake_underlings).to_not include(@barney)
        end
      end

    end

    describe 'belongs to fields' do
      it 'finds via a belongs to field' do
        organization = @database.find(FakeOrganization.name.to_s, '_id', 1).first
        employee = @database.find(FakeEmployee.name.to_s, '_id', 1).first
        expect(employee.fake_organization).to eq organization
      end

      it 'returns nil if organization does not exist' do
        employee = @database.find(FakeEmployee.name.to_s, '_id', 3).first
        expect(employee.fake_organization).to be_nil
      end

      it 'finds via an alternate id' do
        organization = @database.find(FakeOrganization.name.to_s, '_id', 2).first
        secret_employee = @database.find(FakeHiredGoon.name.to_s, '_id', 1).first
        expect(secret_employee.fake_secret_org).to eq organization
      end
    end
  end

end
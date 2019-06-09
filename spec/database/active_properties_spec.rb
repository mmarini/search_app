require 'spec_helper'

class FakeRecord
  include ActiveProperties

  has_properties :attr_a, :attr_b, :attr_c
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

end
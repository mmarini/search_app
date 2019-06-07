require 'spec_helper'

class FakeClass
  include Entity

  attr_reader :attr_a, :attr_b, :attr_c

end

describe Entity do

  let(:subject) { FakeClass.new({ attr_a: "value a", attr_b: 123, attr_c: [1,"2", 3], attr_d: "There is no attr_d"}) }

  context 'attributes' do
    it { should respond_to :attr_a }
    it { should respond_to :attr_b }
    it { should respond_to :attr_c }

    it "assigns attr_a correctly" do
      expect(subject.attr_a).to eql "value a"
    end

    it "assigns attr_b correctly" do
      expect(subject.attr_b).to eql 123
    end

    it "assigns attr_c correctly" do
      expect(subject.attr_c).to eql [1,"2", 3]
    end

    it "does not assign attr_d" do
      expect{ subject.attr_d }.to raise_error(NoMethodError)
    end


  end

end
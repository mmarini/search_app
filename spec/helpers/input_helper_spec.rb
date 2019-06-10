require 'spec_helper'

describe InputHelper do

  let(:subject) { described_class }

  describe '.format_for_searching' do
    it 'returns an integer' do
      expect( subject.format_for_searching('123') ).to eql 123
    end

    it 'returns true' do
      expect( subject.format_for_searching('true') ).to eql true
    end

    it 'returns false' do
      expect( subject.format_for_searching('false') ).to eql false
    end

    it 'returns the string' do
      expect( subject.format_for_searching('123truefalse') ).to eql '123truefalse'
    end


  end
end
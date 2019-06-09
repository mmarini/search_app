require 'spec_helper'

class TestValidator
  include Validators
end

describe Validators do

  let(:subject) { TestValidator.new }

  describe '.validate_string_presence' do
    it 'raises an error if the string is nil' do
      expect{ subject.validate_string_presence(nil, 'label') }.to raise_error(StandardError, 'label cannot be nil')
    end

    it 'raises an error if the string is blank' do
      expect{ subject.validate_string_presence('  ', 'label') }.to raise_error(StandardError, 'label cannot be blank')
    end

    it 'returns the string trimmed' do
      expect(subject.validate_string_presence(' my_string   ', 'label')).to eql 'my_string'
    end
  end
end
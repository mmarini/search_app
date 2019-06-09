require 'spec_helper'

class TestStringHelper
  include StringHelper
end

describe StringHelper do

  let(:subject) { TestStringHelper.new }

  describe '.underscore' do
    it 'converts camel case to snake case' do
      expect( subject.underscore('ThisIsACamelCaseString') ).to eql 'this_is_a_camel_case_string'
    end

    it 'does nothing if nil passed in' do
      expect( subject.underscore(nil) ).to be_nil
    end

  end
end
require 'spec_helper'

class TestStringHelper
  include Helper::StringHelper
end

describe Helper::StringHelper do

  let(:subject) { TestStringHelper.new }

  describe '.underscore' do
    it 'converts camel case to snake case' do
      expect( subject.underscore('ThisIsACamelCaseString') ).to eql 'this_is_a_camel_case_string'
    end

    it 'strips out module names' do
      expect( subject.underscore('Module1::Module2::ThisIsACamelCaseString') ).to eql 'this_is_a_camel_case_string'
    end

    it 'does nothing if nil passed in' do
      expect( subject.underscore(nil) ).to be_nil
    end
  end
end
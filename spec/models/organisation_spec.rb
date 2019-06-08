require 'spec_helper'

describe Organisation do

  let(:subject) { described_class.new({}) }

  context 'attributes' do
    it { should respond_to :_id }
    it { should respond_to :url }
    it { should respond_to :external_id }
    it { should respond_to :name }
    it { should respond_to :domain_names }
    it { should respond_to :created_at }
    it { should respond_to :details }
    it { should respond_to :shared_tickets }
    it { should respond_to :tags }
  end

end
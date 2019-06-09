require 'spec_helper'

describe Ticket do

  let(:subject) { described_class.new({}) }

  context 'attributes' do
     it { should respond_to :_id } 
     it { should respond_to :url } 
     it { should respond_to :external_id } 
     it { should respond_to :created_at } 
     it { should respond_to :type } 
     it { should respond_to :subject } 
     it { should respond_to :description } 
     it { should respond_to :priority } 
     it { should respond_to :status } 
     it { should respond_to :submitter_id } 
     it { should respond_to :assignee_id } 
     it { should respond_to :organization_id } 
     it { should respond_to :tags } 
     it { should respond_to :has_incidents } 
     it { should respond_to :due_at } 
     it { should respond_to :via }
  end

  context 'associations' do
     it { should respond_to :submitted_by }
     it { should respond_to :assigned_to }
     it { should respond_to :organization }
  end

end
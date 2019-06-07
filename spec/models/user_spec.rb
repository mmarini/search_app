require 'spec_helper'

describe User do

  let(:subject) { User.new({}) }

  context 'attributes' do
      it { should respond_to :_id } 
      it { should respond_to :url } 
      it { should respond_to :external_id } 
      it { should respond_to :name } 
      it { should respond_to :alias } 
      it { should respond_to :created_at } 
      it { should respond_to :active } 
      it { should respond_to :verified } 
      it { should respond_to :shared } 
      it { should respond_to :locale } 
      it { should respond_to :timezone } 
      it { should respond_to :last_login_at }
      it { should respond_to :email } 
      it { should respond_to :phone } 
      it { should respond_to :signature } 
      it { should respond_to :organization_id } 
      it { should respond_to :tags } 
      it { should respond_to :suspended } 
      it { should respond_to :role }
  end

end
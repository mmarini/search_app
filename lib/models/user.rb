class User

  include ActiveProperties

  has_properties :url, :external_id, :name, :alias, :created_at, :active, :verified, :shared, :locale,
              :timezone, :last_login_at, :email, :phone, :signature, :organization_id, :tags, :suspended,
              :role
  
  has_many :submitted_tickets, 'Ticket', :submitter_id
  has_many :assigned_tickets, 'Ticket', :assignee_id

  belongs_to :organization, 'Organization'

end
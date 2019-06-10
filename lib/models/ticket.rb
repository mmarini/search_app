module Models
 class Ticket

  include ActiveProperties

  has_properties :url, :external_id, :created_at, :type, :subject, :description, :priority, :status,
               :submitter_id, :assignee_id, :organization_id, :tags, :has_incidents, :due_at, :via

  belongs_to :submitted_by, 'User', :submitter_id
  belongs_to :assigned_to, 'User', :assignee_id
  belongs_to :organization, 'Organization'

 end
end
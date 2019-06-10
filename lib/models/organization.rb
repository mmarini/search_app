module Models
  class Organization

    include ActiveProperties

    has_properties :url, :external_id, :name, :domain_names, :created_at, :details, :shared_tickets, :tags

    has_many :users, 'User'
    has_many :tickets, 'Ticket'

  end
end
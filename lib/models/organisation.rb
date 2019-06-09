class Organisation

  include ActiveProperties

  has_properties :_id, :url, :external_id, :name, :domain_names, :created_at, :details, :shared_tickets, :tags


end
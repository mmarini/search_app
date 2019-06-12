module Views
  class Organization
    def self.format(organization)
      [
          ['_id', organization._id],
          ['url', organization.url],
          ['external_id', organization.external_id],
          ['name', organization.name],
          ['created_at', organization.created_at],
          ['details', organization.details],
          ['shared_tickets', organization.shared_tickets],
          ['tags', organization.tags.join("\n")],
          ['users', organization.users.map { |user| user.name }.join("\n")],
          ['tickets', organization.tickets.map { |ticket| "#{ticket.type} - #{ticket.subject}" }.join("\n")]
      ]
    end
  end
end
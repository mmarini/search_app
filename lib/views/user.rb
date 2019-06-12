module Views
  class User

    def self.format(user)
      [
        ['_id', user._id],
        ['url', user.url],
        ['external_id', user.external_id],
        ['name', user.name],
        ['alias', user.alias],
        ['created_at', user.created_at],
        ['active', user.active],
        ['verified', user.verified],
        ['shared', user.shared],
        ['locale', user.locale],
        ['timezone', user.timezone],
        ['last_login_at', user.last_login_at],
        ['email', user.email],
        ['phone', user.phone],
        ['signature', user.signature],
        ['suspended', user.suspended],
        ['role', user.role],
        ['tags', user.tags.join("\n")],
        ['organization', user.organization&.name || ''],
        ['submitted tickets', user.submitted_tickets.map { |ticket| "#{ticket.type} - #{ticket.subject}" }.join("\n")],
        ['assigned tickets', user.assigned_tickets.map { |ticket| "#{ticket.type} - #{ticket.subject}" }.join("\n")]
      ]
    end

  end
end
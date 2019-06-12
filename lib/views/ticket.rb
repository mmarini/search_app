module Views
  class Ticket

    def self.format(ticket)
      [
          ['_id', ticket._id],
          ['url', ticket.url],
          ['external_id', ticket.external_id],
          ['created_at', ticket.created_at],
          ['type', ticket.type],
          ['subject', ticket.subject],
          ['description', ticket.description],
          ['priority', ticket.priority],
          ['status', ticket.status],
          ['has_incidents', ticket.has_incidents],
          ['due_at', ticket.due_at],
          ['via', ticket.via],
          ['tags', ticket.tags.join("\n")],
          ['organization', ticket.organization&.name || ''],
          ['submitted by', ticket.submitted_by&.name || ''],
          ['assigned to', ticket.assigned_to&.name || '']
      ]
    end

  end
end
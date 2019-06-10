require 'spec_helper'

describe Views::Ticket do

  before(:each) do
    Database.instance.clear!
  end

  let(:subject) { described_class }
  let(:ticket) { Models::Ticket.new(
      {
          "_id" => "1a227508-9f39-427c-8f57-1b72f3fab87c",
          "url" => "http://initech.zendesk.com/api/v2/tickets/1a227508-9f39-427c-8f57-1b72f3fab87c.json",
          "external_id" => "3e5ca820-cd1f-4a02-a18f-11b18e7bb49a",
          "created_at" => "2016-04-14T08:32:31 -10:00",
          "type" => "incident",
          "subject" => "A Catastrophe in Micronesia",
          "description" => "Aliquip excepteur fugiat ex minim ea aute eu labore. Sunt eiusmod esse eu non commodo est veniam consequat.",
          "priority" => "low",
          "status" => "hold",
          "submitter_id" => 71,
          "assignee_id" => 38,
          "organization_id" => 112,
          "tags" => [
              "Puerto Rico",
              "Idaho",
              "Oklahoma",
              "Louisiana"
          ],
          "has_incidents" => false,
          "due_at" => "2016-08-15T05:37:32 -10:00",
          "via" => "chat"
      }
  ) }

  let(:organization) { Models::Organization.new(
      {
          "_id" => 112,
          "url" => "http://initech.zendesk.com/api/v2/organizations/117.json",
          "external_id" => "bf9b5a96-9b10-45ff-b638-a374a521dead",
          "name" => "Comtext"
      }
  ) }

  let(:user_1) { Models::User.new(
      {
          "_id" => 71,
          "organization_id" => 112,
          "name" => "Submitted User"
      }
  )}

  let(:user_2) { Models::User.new(
      {
          "_id" => 38,
          "organization_id" => 112,
          "name" => "Assigned User"
      }
  )}

  it 'renders a ticket' do

    table = Database.instance.add_table('Organization')
    table.add_entry(organization)

    table = Database.instance.add_table('Ticket')
    table.add_entry(ticket)

    table = Database.instance.add_table('User')
    table.add_entry(user_1)
    table.add_entry(user_2)

    results = subject.format(ticket)
    expect(results.count).to eq 16
    expect(results).to include(["_id", "1a227508-9f39-427c-8f57-1b72f3fab87c"])
    expect(results).to include(["url", "http://initech.zendesk.com/api/v2/tickets/1a227508-9f39-427c-8f57-1b72f3fab87c.json"])
    expect(results).to include(["external_id", "3e5ca820-cd1f-4a02-a18f-11b18e7bb49a"])
    expect(results).to include(["created_at", "2016-04-14T08:32:31 -10:00"])
    expect(results).to include(["type", "incident"])
    expect(results).to include(["subject", "A Catastrophe in Micronesia"])
    expect(results).to include(["description", "Aliquip excepteur fugiat ex minim ea aute eu labore. Sunt eiusmod esse eu non commodo est veniam consequat."])
    expect(results).to include(["priority", "low"])
    expect(results).to include(["status", "hold"])
    expect(results).to include(["priority", "low"])
    expect(results).to include(["has_incidents", false])
    expect(results).to include(["due_at", "2016-08-15T05:37:32 -10:00"])
    expect(results).to include(["via", "chat"])
    expect(results).to include(["tags", "Puerto Rico\nIdaho\nOklahoma\nLouisiana"])
    expect(results).to include(["organization", "Comtext"])
    expect(results).to include(["submitted by", "Submitted User"])
    expect(results).to include(["assigned to", "Assigned User"])
  end

  it 'does not display associated records if there are none' do
    results = subject.format(ticket)
    expect(results).to include(["organization", ""])
    expect(results).to include(["submitted by", ""])
    expect(results).to include(["assigned to", ""])
  end
end
require 'spec_helper'

describe Views::User do

  before(:each) do
    Database::Database.instance.clear!
  end

  let(:subject) { described_class }
  let(:user) { Models::User.new(
      {
          "_id" => 3,
          "url" => "http://initech.zendesk.com/api/v2/users/3.json",
          "external_id" => "85c599c1-ebab-474d-a4e6-32f1c06e8730",
          "name" => "Ingrid Wagner",
          "alias" => "Miss Buck",
          "created_at" => "2016-07-28T05:29:25 -10:00",
          "active" => false,
          "verified" => false,
          "shared" => false,
          "locale" => "en-AU",
          "timezone" => "Trinidad and Tobago",
          "last_login_at" => "2013-02-07T05:53:38 -11:00",
          "email" => "buckwagner@flotonic.com",
          "phone" => "9365-482-943",
          "signature" => "Don't Worry Be Happy!",
          "organization_id" => 104,
          "tags" => [
              "Mulino",
              "Kenwood",
              "Wescosville",
              "Loyalhanna"
          ],
          "suspended" => false,
          "role" => "end-user"
      }
  ) }

  let(:ticket_1) { Models::Ticket.new(
      {
          "_id" => "1a227508-9f39-427c-8f57-1b72f3fab87c",
          "organization_id" => 117,
          "type" => "incident",
          "subject" => "Submitted Ticket",
          "submitter_id" => 3
      }
  ) }

  let(:ticket_2) { Models::Ticket.new(
      {
          "_id" => "1a227508-9f39-427c-8f57-1b72f3fab87d",
          "organization_id" => 117,
          "type" => "bug",
          "subject" => "Assigned Ticket",
          "assignee_id" => 3
      }
  ) }

  let(:organization) { Models::Organization.new(
      {
          "_id" => 104,
          "url" => "http://initech.zendesk.com/api/v2/organizations/117.json",
          "external_id" => "bf9b5a96-9b10-45ff-b638-a374a521dead",
          "name" => "Comtext"
      }
  ) }

  it 'renders a ticket' do
    table = Database::Database.instance.add_table('Organization')
    table.add_entry(organization)

    table = Database::Database.instance.add_table('Ticket')
    table.add_entry(ticket_1)
    table.add_entry(ticket_2)

    table = Database::Database.instance.add_table('User')
    table.add_entry(user)

    results = subject.format(user)
    expect(results.count).to eq 21
    expect(results).to include(["_id", 3])
    expect(results).to include(["url", "http://initech.zendesk.com/api/v2/users/3.json"])
    expect(results).to include(["external_id", "85c599c1-ebab-474d-a4e6-32f1c06e8730"])
    expect(results).to include(["name", "Ingrid Wagner"])
    expect(results).to include(["alias", "Miss Buck"])
    expect(results).to include(["created_at", "2016-07-28T05:29:25 -10:00"])
    expect(results).to include(["active", false])
    expect(results).to include(["verified", false])
    expect(results).to include(["shared", false])
    expect(results).to include(["locale", "en-AU"])
    expect(results).to include(["timezone", "Trinidad and Tobago"])
    expect(results).to include(["last_login_at", "2013-02-07T05:53:38 -11:00"])
    expect(results).to include(["email", "buckwagner@flotonic.com"])
    expect(results).to include(["phone", "9365-482-943"])
    expect(results).to include(["signature", "Don't Worry Be Happy!"])
    expect(results).to include(["suspended", false])
    expect(results).to include(["role", "end-user"])
    expect(results).to include(["tags", "Mulino\nKenwood\nWescosville\nLoyalhanna"])
    expect(results).to include(["organization", "Comtext"])
    expect(results).to include(["submitted tickets", "incident - Submitted Ticket"])
    expect(results).to include(["assigned tickets", "bug - Assigned Ticket"])
  end

  it 'does not display associated records if there are none' do
    results = subject.format(user)
    expect(results).to include(["organization", ""])
    expect(results).to include(["submitted tickets", ""])
    expect(results).to include(["assigned tickets", ""])
  end
end
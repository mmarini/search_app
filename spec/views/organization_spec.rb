require 'spec_helper'

describe Views::Organization do

  before(:each) do
    Database.instance.clear!
  end

  let(:subject) { described_class }
  let(:organization) { Models::Organization.new(
                        {
                          "_id" => 117,
                          "url" => "http://initech.zendesk.com/api/v2/organizations/117.json",
                          "external_id" => "bf9b5a96-9b10-45ff-b638-a374a521dead",
                          "name" => "Comtext",
                          "domain_names" => [
                              "aquazure.com",
                              "keeg.com",
                              "eventex.com",
                              "zillar.com"
                          ],
                          "created_at" => "2016-03-17T08:48:21 -11:00",
                          "details" => "Artisan",
                          "shared_tickets" => true,
                          "tags" => [
                              "Burris",
                              "Ortiz",
                              "Langley",
                              "Wall"
                          ]
                      }
                      ) }

  let(:ticket_1) { Models::Ticket.new(
      {
          "_id" => "1a227508-9f39-427c-8f57-1b72f3fab87c",
          "organization_id" => 117,
          "type" => "incident",
          "subject" => "Subject 1"
      }
  ) }

  let(:ticket_2) { Models::Ticket.new(
      {
          "_id" => "1a227508-9f39-427c-8f57-1b72f3fab87d",
          "organization_id" => 117,
          "type" => "bug",
          "subject" => "Subject 2"
      }
  ) }

  let(:user_1) { Models::User.new(
     {
        "_id" => 1,
        "organization_id" => 117,
        "name" => "User 1"
     }
  )}

  let(:user_2) { Models::User.new(
      {
          "_id" => 2,
          "organization_id" => 117,
          "name" => "User 2"
      }
  )}

  it 'renders an organization' do

    table = Database.instance.add_table('Organization')
    table.add_entry(organization)

    table = Database.instance.add_table('Ticket')
    table.add_entry(ticket_1)
    table.add_entry(ticket_2)

    table = Database.instance.add_table('User')
    table.add_entry(user_1)
    table.add_entry(user_2)

    results = subject.format(organization)
    expect(results.count).to eq 10
    expect(results).to include(["_id", 117])
    expect(results).to include(["url", "http://initech.zendesk.com/api/v2/organizations/117.json"])
    expect(results).to include(["external_id", "bf9b5a96-9b10-45ff-b638-a374a521dead"])
    expect(results).to include(["name", "Comtext"])
    expect(results).to include(["created_at", "2016-03-17T08:48:21 -11:00"])
    expect(results).to include(["details", "Artisan"])
    expect(results).to include(["shared_tickets", true])
    expect(results).to include(["tags", "Burris\nOrtiz\nLangley\nWall"])
    expect(results).to include(["users", "User 1\nUser 2"])
    expect(results).to include(["tickets", "incident - Subject 1\nbug - Subject 2"])
  end

  it 'does not display associated records if there are none' do
    results = subject.format(organization)
    expect(results).to include(["users", ""])
    expect(results).to include(["tickets", ""])
  end

end
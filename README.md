# search_app

## How to run

Pre-requisites: 
- Solution coded against ruby 2.6.3
- Please run a `bundle install` from the `search_app` directory to install any required libraries

From the search_app directory, run `bundle exec ./bin/search.rb`

You will be presented with a menu that will prompt you for the following:

    Welcome to the Zendesk search app
    1. Search Zendesk
    2. List Searchable Fields
    3. Quit
    Please select an option

Option 1 (Search Zendesk) will prompt you for more information:

    What would you like to search on? (Use arrow keys, press Enter to select, and letter keys to filter)
    ‣ Organization
      Ticket
      User
    Choose the field to search against (Use arrow keys, press Enter to select, and letter keys to filter)
    ‣ _id
      url
      external_id
      name
      domain_names
      created_at
    (Move up or down to reveal more choices)
    Enter search value
    117
    Field Name     Value
    _id            117
    url            http://initech.zendesk.com/api/v2/organizations/117.json
    external_id    bf9b5a96-9b10-45ff-b638-a374a521dead
    name           Comtext
    created_at     2016-03-17T08:48:21 -11:00
    details        Artisan
    shared_tickets true
    tags           Burris
                   Ortiz
                   Langley
                   Wall
    users
    tickets        problem - A Problem in United Kingdom
                   incident - A Catastrophe in Cook Islands
                   incident - A Catastrophe in New Zealand
                   problem - A Drama in Qatar
                   task - A Drama in Burundi
    -------------------------------------------------------
    Returned 1 entries of type Organization

The options for selecting the type (Organization, Ticket, User) uses the arrow keys to select
The options for selecting the field to search against also uses the arrow keys, but also enables you to filter that list
by typing

Option 2 (List Searchable Fields) will display a list of searchable fields:

    Welcome to the Zendesk search app
    1. Search Zendesk
    2. List Searchable Fields
    3. Quit
    Please select an option
    2
    Search Organization with:
    _id
    url
    external_id
    name
    domain_names
    created_at
    details
    shared_tickets
    tags
    
    --------------------------
    Search Ticket with:
    _id
    url
    external_id
    created_at
    type
    subject
    description
    priority
    status
    submitter_id
    assignee_id
    organization_id
    tags
    has_incidents
    due_at
    via
    
    --------------------------
    Search User with:
    _id
    url
    external_id
    name
    alias
    created_at
    active
    verified
    shared
    locale
    timezone
    last_login_at
    email
    phone
    signature
    organization_id
    tags
    suspended
    role
    
    --------------------------

The results for the search and listing the search fields will scroll similar to the `less` command. Use the arrow keys 
to scroll up and down, a space to scroll down a page, or press `q` to quit the results

## Tests
Tests were written with RSpec and are located in the `spec` directory . Please run `bundle exec rspec` to execute

## Design Decisions

### Database
In order to search, models are added to an internal database. There is only 1 database instance (it's a singleton), 
which contains many tables. Each table has to have a unique name. There is 1 table per object type (Organisation, User, 
Ticket). The objects are stored in an array on the table.

Each table also has many indexes. The index is a hash of values, which returns a set of positions of where the objects
are stored within the table. Currently, every field on a model is indexed, but it doesn't have to be that way.
The indexable_fields method on each model could be overridden if only a select number of fields are to be indexed.

The index will index the value as is. If the value is an Array, it will index each item in the array.

### Models
Each of the three models (Organisation, Ticket, User) maps to each of the test files that was provided for the 
coding challenge.

The models were originally looking like this:

    class Organization

      attr_reader :_id, url, ...
  
      def initialize(args)
        @_id = args['_id']
        @url = args['url']
        ...
      end
  
      def indexable_fields
        ['_id', 'url', ...]
      end  
  
      def users
        database = Database.instance
        database.find(User, 'organization_id', self._id)
      end
  
      def tickets
        database = Database.instance
        database.find(Ticket, 'organization_id', self._id)
      end
    end

So there were patterns emerging here:
- Every object type had an '_id' attribute as it's primary lookup
- The properties specified in attr_reader and the indexable_fields were the same
- Each model was going to have their attributes initialized by a hash as parsed by the importer
- The methods to get associated objects were going to find those objects in a consistent way

After reviewing, I decided to refactor these off into active_properties module which:
- specifies a has_properties method which:
  - automatically adds an '_id' property
  - adds attr_reader on each of the properties specified
  - stores the properties so they can be used for the indexable_properties list
- specifies a has_many method which:
  - performs the database lookup to return associated child objects in a parent-child relationship  
- specifies a belongs_to method which:
  - performs the database lookup to return associated parent objects in a parent-child relationship
  
Moving these into a separate module also had the benefit of moving any database implementation items out of the models
themselves, so I could then move that module to the database directory

### Importer
The importer takes a file name and parses the contents to initialize instances of the models. It also takes in a block
so we can perform actions on the objects as they are created

### Views
A view will take in the object and format it for display. The format is a an array of arrays that can be taken in by the
tty-table gem

### Helpers
Code that helps with items like validation, string formatting and input formatting goes here

### App
The app directory contains the code for the UI menus and prompting. Each action (search, list fields) has their own 
action class
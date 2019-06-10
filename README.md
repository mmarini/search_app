# search_app

## Design Decisions

## Database
In order to search, models are added to an internal database. There is only 1 database instance (it's a singleton), 
which contains many tables. There is 1 table per object type (Organisation, User, Ticket). The objects are stored in
an array on the table.

Each table also has many indexes. The index is a hash of values, which returns a set of positions of where the objects
are stored within the table. Currently, every field on a model is indexed, but it doesn't have to be that way.
The indexable_fields method on each model could be overridden if only a select number of fields are to be indexed.

## Models
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
- Every object type had a '_id' attribute as it's primary lookup
- The the properties specified in attr_reader and the indexable_fields were the same
- Each model was going to have their attributes initialized by a hash as parsed by the importer
- The methods to get associated objects were going to find those objects in a consistant way

After reviewing, I decided to refactor these off into active_properties module which:
- specifies a has_properties method which:
  - automatically adds an '_id' property
  - adds attr_reader on each of the properties specified
  - stores the properties so they can be used for the indexable_properties list
- specifies a has_many method which:
  - performs the database lookup to return associated child objects in a parent-child relationship  
- specifies a belongs_to method which:
  - performs the database lookup to return associated parent objects in a parent-child relationship
  
Moving these into a separate module had the benefit of moving any database implementation items out of the models
themselves, so I could then move that module to the database directory

## Importer
The importer takes a file name and parses the contents to initialize instances of the models

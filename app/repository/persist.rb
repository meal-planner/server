module MealPlanner
  module Repository
    # add persist method to repository
    # which saves or updates given document
    # and sets the document id for newly created documents
    module Persist
      def persist(document)
        if document.id
          update document
        else
          result = save document
          document.id = result['_id']
        end
      end
    end
  end
end

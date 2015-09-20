module MealPlanner
  module Repository
    # remove object id before indexing
    # restore object id after getting from index
    module Serializer
      def self.included(base)
        base.class_eval do
          def serialize(document)
            document.to_hash.except(:id, 'id')
          end

          def deserialize(document)
            object = klass.new document['_source']
            object.instance_variable_set :@id, document['_id']

            object
          end
        end
      end
    end
  end
end

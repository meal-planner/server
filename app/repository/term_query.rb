module MealPlanner
  module Repository
    # adds ElasticSearch term query (exact match)
    module TermQuery
      def term_query(field, value)
        query = {
          query: {
            filtered: {
              filter: {
                term: { field => value }
              }
            }
          }
        }
        search query
      end
    end
  end
end

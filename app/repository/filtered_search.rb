module MealPlanner
  module Repository
    # adds ElasticSearch filtered query
    # search query text and filter are optional
    module FilteredSearch
      def filtered_search(text: nil, filter_by: nil, filter_value: nil,
                          start: nil, size: nil)
        query = {
          query: { filtered: {} },
          from: start || 0, size: size || 12
        }
        filter_query(query, filter_by, filter_value)
        text_query(query, text)
        search query
      end

      private

      def filter_query(query, filter_by, filter_value)
        return unless filter_value.present?
        query[:query][:filtered][:filter] = {
          term: { filter_by => filter_value }
        }
      end

      def text_query(query, text)
        return unless text.present?
        query[:query][:filtered][:query] = {
          match: { name: text }
        }
      end
    end
  end
end

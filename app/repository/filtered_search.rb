module MealPlanner
  module Repository
    module FilteredSearch
      def filtered_search(text: nil, filter_by: nil, filter_value: nil, start: nil, size: nil)
        query = {
            query: {
                filtered: {}
            },
            from: start || 0,
            size: size || 12
        }
        query[:query][:filtered][:filter] = {term: {filter_by => filter_value}} if filter_value.present?
        query[:query][:filtered][:query] = {match: {name: text}} if text.present?

        search query
      end
    end
  end
end
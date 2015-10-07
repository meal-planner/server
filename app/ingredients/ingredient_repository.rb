# Ingredient storage ElasticSearch repository
class IngredientRepository
  include Elasticsearch::Persistence::Repository
  include MealPlanner::Repository::Serializer
  extend MealPlanner::Repository::Validator
  extend MealPlanner::Repository::FilteredSearch

  klass Ingredient
  validator IngredientValidator

  index :ingredients
  type :ingredient

  def self.find_by_ids(ids)
    search({ query: { ids: { values: ids } } })
  end
end

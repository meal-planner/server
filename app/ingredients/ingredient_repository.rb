# Ingredient storage ElasticSearch repository
class IngredientRepository
  include Elasticsearch::Persistence::Repository
  include MealPlanner::Repository::Serializer
  extend MealPlanner::Repository::Validator
  extend MealPlanner::Repository::FilteredSearch
  extend MealPlanner::Repository::Persist

  client Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'], log: true

  klass Ingredient
  validator IngredientValidator

  index :ingredients
  type :ingredient

  def self.find_by_ids(ids)
    search({ query: { ids: { values: ids } } })
  end
end

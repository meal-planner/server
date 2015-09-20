# Recipe storage ElasticSearch repository
class RecipeRepository
  include Elasticsearch::Persistence::Repository
  include MealPlanner::Repository::Serializer
  extend MealPlanner::Repository::Validator
  extend MealPlanner::Repository::FilteredSearch

  klass Recipe
  validator RecipeValidator

  index :recipes
  type :recipe
end

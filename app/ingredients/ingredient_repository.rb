class IngredientRepository
  include Elasticsearch::Persistence::Repository
  include MealPlanner::Repository::Store
  extend MealPlanner::Repository::Validator
  extend MealPlanner::Repository::FilteredSearch

  klass Ingredient
  validator IngredientValidator

  index :ingredients
  type  :ingredient
end
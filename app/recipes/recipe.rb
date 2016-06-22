# Recipe entity
class Recipe
  include Virtus.model
  include MealPlanner::Repository::Model
  include MealPlanner::Repository::Model::CanBeOwned
  include MealPlanner::Repository::Model::HasImage
  # Recipe ingredient entity
  class Ingredient
    include Virtus.model

    attribute :id, String
    attribute :measure, String
    attribute :measure_amount, Float
    attribute :position, Integer
  end

  attribute :name, String
  attribute :time_to_cook, Integer
  attribute :servings, Integer
  attribute :ingredients, Array[Ingredient]
  attribute :nutrients, Hash[Symbol => Float]
  attribute :steps, Array[String]
  attribute :dish_type, String
  attribute :cuisine, Array[String]
  attribute :key_ingredient, Array[String]
  attribute :diet, Array[String]
end

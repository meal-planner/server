# Recipe entity
class Recipe
  include Virtus.model
  include MealPlanner::Repository::Model
  include MealPlanner::Repository::Model::CanBeOwned
  # Recipe ingredient entity
  class Ingredient
    include Virtus.model

    attribute :id, String
    attribute :name, String
    attribute :image_url, String
    attribute :measure, String
    attribute :measure_amount, Float
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

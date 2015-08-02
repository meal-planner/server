require 'elasticsearch/persistence/model'

class Recipe
  include Elasticsearch::Persistence::Model

  class Ingredient
    include Virtus.model

    attribute :id, String
    attribute :name, String
    attribute :measure, String
    attribute :measure_amount, Integer
  end

  attribute :name, String
  attribute :time_to_cook, Integer
  attribute :servings, Integer
  attribute :serving_size, Integer
  attribute :serving_label, String
  attribute :ingredients, Array[Ingredient]
  attribute :nutrients, Hash[Symbol => Float]
  attribute :steps, Array[String]
  attribute :dish_type, String
  attribute :cuisine, Array[String]
  attribute :key_ingredient, Array[String]
  attribute :diet, Array[String]

  validates :name, presence: true
  validates :time_to_cook, presence: true
  validates :ingredients, presence: true
  validates :nutrients, presence: true
  validates :steps, presence: true
end
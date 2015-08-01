require 'elasticsearch/persistence/model'

class Recipe
  include Elasticsearch::Persistence::Model

  attribute :name, String
  attribute :time_to_cook, Integer
  attribute :servings, Integer
  attribute :serving_size, Integer
  attribute :serving_label, String
  attribute :ingredients, Array
  attribute :nutrients, Hash
  attribute :steps, Array
  attribute :dish_type, String
  attribute :cuisine, Array
  attribute :key_ingredient, Array
  attribute :diet, Array

  validates :name, presence: true
  validates :time_to_cook, presence: true
  validates :ingredients, presence: true
  validates :nutrients, presence: true
  validates :steps, presence: true
end
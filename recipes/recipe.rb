require 'elasticsearch/persistence/model'

class Recipe
  include Elasticsearch::Persistence::Model

  attribute :name, String
  attribute :time_to_cook, String
  attribute :ingredients, Array
  attribute :steps, Array

  validates :name, presence: true
  validates :time_to_cook, presence: true
  validates :ingredients, presence: true
  validates :steps, presence: true
end
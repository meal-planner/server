require 'elasticsearch/persistence/model'

class Recipe
  include Elasticsearch::Persistence::Model

  attribute :name, String
  attribute :time_to_cook, String
  attribute :directions, String
  attribute :ingredients, Hash

  validates :name, presence: true
  validates :time_to_cook, presence: true
  validates :directions, presence: true
  validates :ingredients, presence: true
end
require 'elasticsearch/persistence/model'

class Ingredient
  include Elasticsearch::Persistence::Model

  attribute :name, String
  attribute :calories, Integer
  attribute :fat, Integer
  attribute :protein, Integer
  attribute :carbohydrate, Integer

  validates :name, presence: true
end
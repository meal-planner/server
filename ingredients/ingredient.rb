require 'elasticsearch/persistence/model'

class Ingredient
  include Elasticsearch::Persistence::Model

  attribute :ndbno, String
  attribute :name, String
  attribute :group, String
  attribute :nutrients, Hash

  validates :name, presence: true
  validates :nutrients, presence: true
end
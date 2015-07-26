require 'elasticsearch/persistence/model'

class Ingredient
  include Elasticsearch::Persistence::Model

  attribute :ndbno, String
  attribute :name, String
  attribute :description, String
  attribute :group, String
  attribute :generic, Boolean
  attribute :measures, Array

  validates :name, presence: true
  validates :measures, presence: true
end
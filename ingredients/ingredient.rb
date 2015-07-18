require 'elasticsearch/persistence/model'

class Ingredient
  include Elasticsearch::Persistence::Model

  attribute :ndbno, String
  attribute :name, String
  attribute :short_name, String
  attribute :group, String
  attribute :measures, Array

  validates :name, presence: true
  validates :measures, presence: true
end
require 'elasticsearch/persistence/model'
require_relative '../ownable'

class Ingredient
  include Elasticsearch::Persistence::Model
  include Ownable

  class Measure
    include Virtus.model

    attribute :qty, Integer
    attribute :eqv, Integer
    attribute :label, String
    attribute :nutrients, Hash[Symbol => Float]
  end

  attribute :ndbno, String
  attribute :name, String
  attribute :description, String
  attribute :group, String
  attribute :generic, Boolean, :default => false
  attribute :measures, Array[Measure]

  validates :name, presence: true
  validates :measures, presence: true
end
# Ingredient entity
class Ingredient
  include Virtus.model
  include MealPlanner::Repository::Model
  include MealPlanner::Repository::Model::CanBeOwned
  include MealPlanner::Repository::Model::HasImage
  # Ingredient measure entity
  class Measure
    include Virtus.model

    attribute :qty, Integer
    attribute :eqv, Integer
    attribute :label, String
    attribute :nutrients, Hash[Symbol => Float]
  end

  attribute :forked_from, String
  attribute :ndbno, String
  attribute :name, String
  attribute :group, String
  attribute :generic, Boolean, default: false
  attribute :measures, Array[Measure]
  attribute :ready_to_eat, Boolean, default: false
end

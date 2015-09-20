class RecipeValidator
  include Veto.validator

  validates :name, presence: true
  validates :time_to_cook, presence: true
  validates :ingredients, presence: true
  validates :nutrients, presence: true
  validates :steps, presence: true
end
# Ingredient attributes validator
class IngredientValidator
  include Veto.validator

  validates :name, presence: true
  validates :measures, presence: true
end

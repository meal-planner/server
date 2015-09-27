require_relative '../meal_planner'

class Converter
  # Set owner to all
  def self.convert(start)
    ingredients = IngredientRepository.search query: {match_all: {}}, sort: [{ndbno: {order: 'asc'}}], from: start, size: 1000
    user_id = 'AU_sYpXkRDQtKjI7qQF7'
    ingredients.each do |ingredient|
      print "Converting #{ingredient.ndbno}..."
      unless ingredient.owner_id == user_id
        ingredient.owner_id = user_id
        IngredientRepository.update ingredient
        puts 'done'
      else
        puts 'skip'
      end
    end
  end
end

0.upto(8).each do |page|
  start = page * 1000
  Converter.convert(start)
end

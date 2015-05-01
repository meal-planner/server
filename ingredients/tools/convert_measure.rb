require_relative 'ingredient'

class Converter
  def self.convert
    ingredients = Ingredient.search query: {match_all: {}}, sort: [{ndbno: {order: 'asc'}}], from: 8000, size: 1000
    ingredients.each do |ingredient|
      print "Converting #{ingredient.ndbno}..."
      new_nutrients = {}
      need_to_save = true
      ingredient.nutrients.each do |nutrient|
        name, data = nutrient[0], nutrient[1]
        if data.has_key?('value')
          default_measure = {
              label: 'g',
              eqv: 100,
              qty: 100,
              value: data['value']
          }
          measures = [default_measure, data['measures']].flatten!
          new_nutrients[name] = {
              group: data['group'],
              unit: data['unit'],
              measures: measures
          }
        else
          need_to_save = false
        end
      end

      if need_to_save
        ingredient.nutrients = new_nutrients
        ingredient.save
        puts 'done'
      else
        puts 'skipped'
      end
    end
  end
end

Converter.convert

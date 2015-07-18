require_relative '../ingredient'

class Converter
  def self.convert
    ingredients = Ingredient.search query: {match_all: {}}, sort: [{ndbno: {order: 'asc'}}], from: 0, size: 1000
    ingredients.each do |ingredient|
      print "Converting #{ingredient.ndbno}..."
      if ingredient.measures.length > 0
        puts 'skip'
      else
        measures = []
        ingredient.nutrients.each do |name, data|
          data['measures'].each_with_index do |measure, index|
            unless measures[index]
              measures[index] = {
                  label: measure['label'],
                  eqv: measure['eqv'],
                  qty: measure['qty'],
                  nutrients: {}
              }
            end
            measures[index][:nutrients][name] = measure['value']
          end
        end
        ingredient.measures = measures
        ingredient.nutrients = nil
        ingredient.save
        puts 'done'
      end
    end
  end
end

Converter.convert

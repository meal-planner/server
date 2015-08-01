require_relative '../ingredient'

class Converter
  # Set empty description field to all ingredients
  def self.convert(start)
    ingredients = Ingredient.search query: {match_all: {}}, sort: [{ndbno: {order: 'asc'}}], from: start, size: 1000

    ingredients.each do |ingredient|
      print "Converting #{ingredient.ndbno}..."
      unless ingredient.description
        ingredient.description = ''
        ingredient.save
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

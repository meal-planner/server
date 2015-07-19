require_relative '../ingredient'

class Converter
  # Convert USDA groups to our shorter list of groups.
  def self.convert(start)
    ingredients = Ingredient.search query: {match_all: {}}, sort: [{ndbno: {order: 'asc'}}], from: start, size: 1000

    group_map = {
      'American Indian/Alaska Native Foods' => 'Other',
      'Baby Foods' => 'Other',
      'Baked Products' => 'Sweets & Deserts',
      'Beef Products' => 'Meat',
      'Breakfast Cereals' => 'Grains',
      'Cereal Grains and Pasta' => 'Grains',
      'Dairy and Egg Products' => 'Dairy & Eggs',
      'Fast Foods' => 'Other',
      'Fats and Oils' => 'Other',
      'Finfish and Shellfish Products' => 'Fish & Seafood',
      'Fruits and Fruit Juices' => 'Fruits',
      'Lamb, Veal, and Game Products' => 'Meat',
      'Legumes and Legume Products' => 'Legumes',
      'Meals, Entrees, and Side Dishes' => 'Other',
      'Nut and Seed Products' => 'Nuts & Seeds',
      'Pork Products' => 'Meat',
      'Poultry Products' => 'Poultry',
      'Restaurant Foods' => 'Other',
      'Sausages and Luncheon Meats' => 'Meat',
      'Snacks' => 'Sweets & Deserts',
      'Soups, Sauces, and Gravies' => 'Other',
      'Spices and Herbs' => 'Other',
      'Sweets' => 'Sweets & Deserts',
      'Vegetables and Vegetable Products' => 'Vegetables'
    }

    ingredients.each do |ingredient|
      print "Converting #{ingredient.ndbno}..."
      if group_map.has_key?(ingredient.group)
        ingredient.group = group_map[ingredient.group]
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

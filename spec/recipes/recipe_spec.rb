require 'rspec'
require_relative '../../meal_planner'

describe 'Recipe Model' do
  context 'creating new model' do
    it 'creates model from object' do
      json = {
        name: 'foo recipe',
        time_to_cook: 5,
        dish_type: 'Snacks',
        cuisine: %w(American Italian),
        key_ingredient: %w(Beef Bread),
        diet: %w(Vegetarian),
        ingredients: [
          {
            id: 'baz_id',
            name: 'baz ingredient',
            measure: 'g',
            measure_amount: 100,
            not_allowed_attr: 'should be filtered out'
          }
        ],
        nutrients: {
          energy: 150
        }
      }

      recipe = Recipe.new json

      expect(recipe.name).to eq json[:name]
      expect(recipe.time_to_cook).to eq json[:time_to_cook]
      expect(recipe.dish_type).to eq json[:dish_type]
      expect(recipe.cuisine).to eq json[:cuisine]
      expect(recipe.key_ingredient).to eq json[:key_ingredient]
      expect(recipe.diet).to eq json[:diet]
      expect(recipe.ingredients.length).to eq 1
      expect(recipe.ingredients[0].id).to eq json[:ingredients][0][:id]
      expect(recipe.ingredients[0].measure).to(
        eq json[:ingredients][0][:measure]
      )
      expect(recipe.ingredients[0].measure_amount).to(
        eq json[:ingredients][0][:measure_amount]
      )
      expect(recipe.nutrients[:energy]).to eq json[:nutrients][:energy]
    end
  end
end

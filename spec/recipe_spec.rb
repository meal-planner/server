ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../app/recipes/api'

describe 'Recipes REST API' do
  include Rack::Test::Methods

  def app
    RecipeAPI.new
  end

  context 'Updating recipe' do
    let(:recipe) { Recipe.new }

    it 'returns 404 if recipe not found' do
      allow(Recipe).to receive(:find).and_raise(Elasticsearch::Persistence::Repository::DocumentNotFound)

      put '/baz'

      expect(last_response.status).to eq 404
    end

    it 'filters recipe request' do
      recipe[:name] = 'name before update'

      allow(Recipe).to receive(:find).and_return(recipe)
      expect(recipe).to receive(:save)

      request = {
          name: 'updated name',
          time_to_cook: 5,
          dish_type: 'Snacks',
          cuisine: %w{American Italian'},
          key_ingredient: %w{Beef Bread},
          ingredients: [
              {
                  id: 'baz_id',
                  name: 'baz ingredient',
                  short_name: 'baz',
                  group: 'baz group',
                  measure: 'g',
                  measure_amount: 100,
                  not_allowed_attr: 'should be filtered out'
              }
          ],
          nutrients: {
              energy: 150
          }
      }

      put '/foo', request.to_json

      expect(last_response).to be_ok
      expect(recipe[:name]).to eq request[:name]
      expect(recipe[:time_to_cook]).to eq request[:time_to_cook]
      expect(recipe[:dish_type]).to eq request[:dish_type]
      expect(recipe[:cuisine]).to eq request[:cuisine]
      expect(recipe[:key_ingredient]).to eq request[:key_ingredient]
      actual_ingredient = recipe[:ingredients].first
      expected_ingredient = request[:ingredients].first
      expect(actual_ingredient['id']).to eq expected_ingredient[:id]
      expect(actual_ingredient['name']).to eq expected_ingredient[:name]
      expect(actual_ingredient['short_name']).to eq expected_ingredient[:short_name]
      expect(actual_ingredient['group']).to eq expected_ingredient[:group]
      expect(actual_ingredient['measure']).to eq expected_ingredient[:measure]
      expect(actual_ingredient['measure_amount']).to eq expected_ingredient[:measure_amount]
      expect(actual_ingredient['not_allowed_attr']).to be_nil
      expect(recipe[:nutrients]['energy']).to eq request[:nutrients][:energy]
    end
  end
end
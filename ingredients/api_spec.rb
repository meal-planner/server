ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative 'api'

describe 'Ingredients REST API' do
  include Rack::Test::Methods

  def app
    IngredientAPI.new
  end

  context 'updating existing ingredient' do
    let(:ingredient) { Ingredient.new }

    it 'returns 404 if ingredient not found' do
      allow(Ingredient).to receive(:find).and_raise(Elasticsearch::Persistence::Repository::DocumentNotFound)

      put '/baz'

      expect(last_response.status).to eq 404
    end

    it 'returns 400 error if request body is empty' do
      allow(Ingredient).to receive(:find).and_return(ingredient)

      put '/baz'

      expect(last_response.status).to eq 400
      expect(last_response.body).to include 'Payload is missing.'
    end

    it 'returns 400 error if request is invalid' do
      allow(Ingredient).to receive(:find).and_return(ingredient)

      put '/baz', '{invalid_json:foo'

      expect(last_response.status).to eq 400
      expect(last_response.body).to include 'Request could not be processed.'
    end

    it 'filters nutrients request' do
      ingredient[:name] = 'name before update'
      ingredient[:short_name] = 'short name before update'
      ingredient[:group] = 'group before update'
      allow(Ingredient).to receive(:find).and_return(ingredient)
      expect(ingredient).to receive(:save)

      request = {
          name: 'ingredient name',
          short_name: 'short name',
          group: 'ingredient group',
          nutrients: {
              energy: {
                  unit: 'kcal',
                  group: 'Proximates',
                  not_allowed_attr: 'should be filtered out',
                  measures: [
                      {
                          qty: 100,
                          label: 'g',
                          eqv: 100,
                          value: 200,
                          baz_attr: 'should also be filtered out'
                      }
                  ]
              }
          }
      }

      put '/fooId', request.to_json

      expect(last_response).to be_ok
      expect(ingredient[:name]).to eq request[:name]
      expect(ingredient[:short_name]).to eq request[:short_name]
      expect(ingredient[:group]).to eq request[:group]
      actual_nutrient = ingredient[:nutrients]['energy']
      expected_nutrient = request[:nutrients][:energy]
      expect(actual_nutrient['unit']).to eq expected_nutrient[:unit]
      expect(actual_nutrient['group']).to eq expected_nutrient[:group]
      expect(actual_nutrient['not_allowed_attr']).to be_nil
      expect(actual_nutrient['measures'][0]['qty']).to eq expected_nutrient[:measures][0][:qty]
      expect(actual_nutrient['measures'][0]['label']).to eq expected_nutrient[:measures][0][:label]
      expect(actual_nutrient['measures'][0]['eqv']).to eq expected_nutrient[:measures][0][:eqv]
      expect(actual_nutrient['measures'][0]['value']).to eq expected_nutrient[:measures][0][:value]
      expect(actual_nutrient['measures'][0]['baz_attr']).to be_nil
    end

    it 'converts measure values to float' do
      allow(Ingredient).to receive(:find).and_return(ingredient)
      expect(ingredient).to receive(:save)

      request = {
          nutrients: {
              energy: {
                  measures: [
                      {
                          value: '100.5f'
                      }
                  ]
              }
          }
      }
      put '/fooId', request.to_json

      expect(last_response).to be_ok
      expect(ingredient[:nutrients]['energy']['measures'][0]['value']).to eq 100.5
    end
  end

end
ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../app/ingredients/api'

describe 'Ingredients REST API' do
  include Rack::Test::Methods

  def app
    IngredientAPI.new
  end

  context 'updating ingredient' do
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

    it 'returns 400 error if measures param is empty' do
      allow(Ingredient).to receive(:find).and_return(ingredient)

      put '/fooId', {name: 'ingredient name'}.to_json

      expect(last_response.status).to eq 400
      expect(last_response.body).to include 'Missing required parameter: measures.'
    end

    it 'filters nutrients request' do
      ingredient[:name] = 'name before update'
      ingredient[:description] = 'description before update'
      ingredient[:group] = 'group before update'
      allow(Ingredient).to receive(:find).and_return(ingredient)
      expect(ingredient).to receive(:save)

      request = {
          name: 'ingredient name',
          description: 'description',
          group: 'ingredient group',
          measures: [
              {
                  qty: 100,
                  label: 'g',
                  eqv: 100,
                  baz_attr: 'should also be filtered out',
                  nutrients: {
                      energy: 100
                  }
              }
          ]
      }

      put '/fooId', request.to_json

      expect(last_response).to be_ok
      expect(ingredient[:name]).to eq request[:name]
      expect(ingredient[:description]).to eq request[:description]
      expect(ingredient[:group]).to eq request[:group]
      expect(ingredient['measures'].size).to eq 1

      actual_measure = ingredient['measures'][0]
      expected_measure = request[:measures][0]
      expect(actual_measure['qty']).to eq expected_measure[:qty]
      expect(actual_measure['label']).to eq expected_measure[:label]
      expect(actual_measure['eqv']).to eq expected_measure[:eqv]
      expect(actual_measure['value']).to eq expected_measure[:value]
      expect(actual_measure['nutrients']['energy']).to eq expected_measure[:nutrients][:energy]
      expect(actual_measure['baz_attr']).to be_nil
    end
  end

end
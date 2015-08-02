ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../../app/ingredients/api'

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

      expect(last_response.status).to eq 422
      expect(last_response.body).to include 'measures'
    end
  end

end
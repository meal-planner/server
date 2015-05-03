ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative 'api'

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
          name: 'updated name'
      }

      put '/foo', request.to_json

      expect(last_response).to be_ok
      expect(recipe[:name]).to eq request[:name]
    end
  end
end
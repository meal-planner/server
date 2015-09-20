ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../../meal_planner'

describe 'Recipes REST API' do
  include Rack::Test::Methods

  def app
    RecipeAPI.new
  end

  context 'Updating recipe' do
    let(:recipe) { Recipe.new }
    let(:user) { User.new }

    before do
      allow(UserRepository).to receive(:find_by_auth_token).and_return(user)
    end

    it 'returns 404 if recipe not found' do
      allow(RecipeRepository).to receive(:find).and_raise(Elasticsearch::Persistence::Repository::DocumentNotFound)

      put '/baz'

      expect(last_response.status).to eq 404
    end

    it 'returns 422 error if required params are missing' do
      allow(RecipeRepository).to receive(:find).and_return(recipe)

      put '/fooId', {foo: 'bar'}.to_json

      expect(last_response.status).to eq 422
      expect(last_response.body).to include 'name'
      expect(last_response.body).to include 'time_to_cook'
      expect(last_response.body).to include 'ingredients'
      expect(last_response.body).to include 'nutrients'
      expect(last_response.body).to include 'steps'
      expect(last_response.body).to include 'is not present'
    end
  end
end
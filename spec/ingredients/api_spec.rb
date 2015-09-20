ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../../meal_planner'

describe 'Ingredients REST API' do
  include Rack::Test::Methods

  def app
    IngredientAPI.new
  end

  context 'updating ingredient' do
    let(:ingredient) { Ingredient.new }
    let(:user) { User.new }

    before do
      allow(UserRepository).to receive(:find_by_auth_token).and_return(user)
    end

    it 'returns 404 if ingredient not found' do
      allow(IngredientRepository).to receive(:find).and_raise(Elasticsearch::Persistence::Repository::DocumentNotFound)

      put '/baz'

      expect(last_response.status).to eq 404
    end

    it 'returns 400 error if request body is empty' do
      allow(IngredientRepository).to receive(:find).and_return(ingredient)

      put '/baz'

      expect(last_response.status).to eq 400
      expect(last_response.body).to include 'Payload is missing'
    end

    it 'returns 400 error if request is invalid' do
      allow(IngredientRepository).to receive(:find).and_return(ingredient)

      put '/baz', '{invalid_json:foo'

      expect(last_response.status).to eq 400
      expect(last_response.body).to include 'Request could not be processed'
    end

    it 'returns 422 error if required params are missing' do
      allow(IngredientRepository).to receive(:find).and_return(ingredient)

      put '/fooId', {foo: 'bar'}.to_json

      expect(last_response.status).to eq 422
      expect(last_response.body).to include 'name'
      expect(last_response.body).to include 'measures'
      expect(last_response.body).to include 'is not present'
    end
  end

end
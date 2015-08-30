ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require_relative '../../app/recipes/api'

describe 'Recipes REST API' do
  include Rack::Test::Methods

  def app
    RecipeAPI.new
  end

  context 'Updating recipe' do
    let(:recipe) { Recipe.new }
    let(:user) { User.new }

    before do
      allow(User).to receive(:find_by_auth_token).and_return(user)
    end

    it 'returns 404 if recipe not found' do
      allow(Recipe).to receive(:find).and_raise(Elasticsearch::Persistence::Repository::DocumentNotFound)

      put '/baz'

      expect(last_response.status).to eq 404
    end
  end
end
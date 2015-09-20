# /ingredients API REST endpoint
class IngredientAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  get '/' do
    search_entities_in(IngredientRepository).to_json
  end

  get '/:id' do
    get_entity_from(IngredientRepository).to_json
  end

  post '/' do
    create_entity_in IngredientRepository
  end

  put '/:id' do
    update_entity_in IngredientRepository
  end
end

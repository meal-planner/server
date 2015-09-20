class RecipeAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::User

  before do
    content_type :json
  end

  get '/' do
    search_entities_in(RecipeRepository).to_json
  end

  get '/:id' do
    get_entity_from(RecipeRepository).to_json
  end

  post '/' do
    create_entity_in RecipeRepository
  end

  put '/:id' do
    update_entity_in RecipeRepository
  end
end
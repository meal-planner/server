# /recipes API REST endpoint
class RecipeAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  get '/' do
    search_entities_in(RecipeRepository).to_json
  end

  get '/:id' do
    recipe = get_entity_from(RecipeRepository)
    ingredient_ids = recipe[:ingredients].map { |ingredient| ingredient.id }
    recipe[:ingredients] = IngredientRepository.find_by_ids ingredient_ids
    recipe.to_json
  end

  post '/' do
    create_entity_in RecipeRepository
  end

  put '/:id' do
    update_entity_in RecipeRepository
  end
end

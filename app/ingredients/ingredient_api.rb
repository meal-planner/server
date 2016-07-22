# /ingredients API REST endpoint
class IngredientAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  get '/' do
    @params[:sort] = [
      { generic: { order: 'desc' } },
      { _score: { order: 'desc' } }
    ]
    search_entities_in(IngredientRepository).to_json
  end

  get '/:id' do
    if params[:id].include?(",")
      IngredientRepository.find_by_ids(params[:id].split(",")).to_json
    else
      get_entity_from(IngredientRepository).to_json
    end
  end

  post '/' do
    create_entity_in IngredientRepository
  end

  put '/:id' do
    update_entity_in IngredientRepository
  end
end

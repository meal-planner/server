# /ingredients API REST endpoint
class IngredientAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::Auth

  before do
    content_type :json
    params.each do |key, value|
      params[key] = nil if value && value.empty?
    end
  end

=begin
@api {get} /ingredients Ingredients List
@apiVersion 0.1.0
@apiName IngredientsList
@apiGroup Ingredients
@apiDescription Ingredients list can be used to retrieve a list of all ingredients,
filtered ingredients or to perform full text search on the ingredients.

@apiParam {String} query Full text search query
@apiParam {String} filter_by Filter attribute name
@apiParam {String} filter_value Filter value
@apiParam {Number} start Initial offset
@apiParam {Number} size Number of entities to return, default is 12
@apiParam {String} sort Sort by attribute name

@apiSuccess {Object[]} items List of ingredients
=end
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

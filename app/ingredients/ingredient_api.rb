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
@api {get} /ingredients List
@apiVersion 0.1.0
@apiName IngredientsList
@apiGroup Ingredients
@apiDescription
Ingredients list can be used to retrieve a list of all ingredients,
filtered ingredients or to perform full text search on the ingredients.

For example, to retrieve list of all vegetables, use `filter_by: group` and `filter_value: Vegetables`

@apiExample {curl} Example usage:
curl -i "https://api.meal-planner.org/ingredients?query=tomatoes&filter_by=group&filter_value=Vegetables"

@apiParam {String} query         Full text search query
@apiParam {String} filter_by     Filter attribute name (`group`, `owner_id`, `generic`, `ready_to_eat`)
@apiParam {String} filter_value  Filter value
@apiParam {Number} start         Initial offset
@apiParam {Number} size          Number of items to return, default is `12`
@apiParam {String} sort          Sort by attribute name

@apiSuccess {Number}   total                     Total number of ingredients matching the query
@apiSuccess {Object[]} items                     List of ingredients
@apiSuccess {String}   items.name                Ingredient name
@apiSuccess {String}   items.group               Ingredient group (Fruits, Vegetables, Grains, etc)
@apiSuccess {Number}   items.ndbno               Ingredient USDA database number
@apiSuccess {Boolean}  items.generic             Is ingredient generic?
@apiSuccess {String}   items.forked_from         Parent ingredient ID, if it was forked
@apiSuccess {Boolean}  items.ready_to_eat        Is ingredient ready to be eaten without cooking?
@apiSuccess {Object[]} items.measures            List of ingredient measures
@apiSuccess {Number}   items.measures.qty        Measure quantity
@apiSuccess {Number}   items.measures.eqv        Measure equivalent in grams
@apiSuccess {String}   items.measures.label      Measure label
@apiSuccess {Hash[]}   items.measures.nutrients  Hash of nutrients values for this measure

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

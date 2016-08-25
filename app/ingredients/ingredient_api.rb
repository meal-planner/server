# /ingredients API REST endpoint
class IngredientAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::Entity,
    MealPlanner::Helper::Auth

  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => ENV['ALLOWED_CORS'],
      'Access-Control-Allow-Methods'      => %w(OPTIONS GET POST),
      'Access-Control-Allow-Headers'      => 'Content-Type'
    remove_empty_params
  end

  after do
    response.body = response.body.to_json
  end

=begin
  @api {get} /ingredients List or search ingredients
  @apiVersion 0.1.0
  @apiName IngredientsList
  @apiGroup Ingredients
  @apiDescription
  Ingredients list can be used to retrieve a list of all ingredients,
  filtered ingredients or to perform full text search on the ingredients.

  For example, to retrieve list of all vegetables, use `filter_by: group` and `filter_value: Vegetables`.

  @apiExample {curl} Search in specific group:
  curl -i "https://api.meal-planner.org/ingredients?query=tomatoes&filter_by=group&filter_value=Vegetables"

  @apiExample {curl} Multiple ingredients by ID:
  curl -i "https://api.meal-planner.org/ingredients?filter_by=id&filter_value=AUwT3jHzWDuaurhTN27e,AUwUkOBnWDuaurhTN3hr"

  @apiParam {String} [query]         Full text search query
  @apiParam {String = 'id','group','owner_id','generic','ready_to_eat'} [filter_by] Filter attribute name
  @apiParam {String} [filter_value]  Filter value
  @apiParam {Number} [start]         Initial offset
  @apiParam {Number} [size=12]       Number of items to return
  @apiParam {String} [sort]          Sort by attribute name

  @apiSuccess {Number}   total                     Total number of ingredients matching the query
  @apiSuccess {Object[]} items                     List of ingredients
  @apiSuccess {String}   items.id                  Ingredient unique ID
  @apiSuccess {String}   items.name                Ingredient name
  @apiSuccess {String}   items.group               Ingredient group (Fruits, Vegetables, Grains, etc)
  @apiSuccess {Number}   items.ndbno               Ingredient USDA database number
  @apiSuccess {Boolean}  items.generic             Is ingredient generic?
  @apiSuccess {String}   items.owner_id            Ingredient owner unique ID
  @apiSuccess {String}   items.image_url           Ingredient image URL (relative to content origin)
  @apiSuccess {Date}     items.created_at          Date when ingredient was created
  @apiSuccess {Date}     items.updated_at          Date when ingredient was updated last time
  @apiSuccess {String}   items.forked_from         Parent ingredient ID, if it was forked
  @apiSuccess {Boolean}  items.ready_to_eat        Is ingredient ready to be eaten without cooking?
  @apiSuccess {Object[]} items.measures            List of ingredient measures
  @apiSuccess {Number}   items.measures.qty        Measure quantity
  @apiSuccess {Number}   items.measures.eqv        Measure equivalent in grams
  @apiSuccess {String}   items.measures.label      Measure label
  @apiSuccess {Hash[]}   items.measures.nutrients  Hash of nutrients values for this measure
=end
  get '/' do
    params[:sort] = [
      { generic: { order: 'desc' } },
      { _score: { order: 'desc' } }
    ]
    result        = search
    {
      total: result.response.hits.total,
      items: result.to_a
    }
  end

=begin
  @api {get} /ingredients/:id Get ingredient information
  @apiVersion 0.1.0
  @apiName IngredientsItem
  @apiGroup Ingredients
  @apiDescription
  Retrieve single ingredient by its unique ID.

  @apiExample {curl} Simple example:
  curl -i "https://api.meal-planner.org/ingredients/AUwT3jHzWDuaurhTN27e"

  @apiParam {String} id Ingredient unique ID

  @apiSuccess {String}   id                  Ingredient unique ID
  @apiSuccess {String}   name                Ingredient name
  @apiSuccess {String}   group               Ingredient group (Fruits, Vegetables, Grains, etc)
  @apiSuccess {Number}   ndbno               Ingredient USDA database number
  @apiSuccess {Boolean}  generic             Is ingredient generic?
  @apiSuccess {Boolean}  can_edit            Only returned if request is made by owner
  @apiSuccess {String}   image_url           Ingredient image URL (relative to content origin)
  @apiSuccess {Date}     created_at          Date when ingredient was created
  @apiSuccess {Date}     updated_at          Date when ingredient was updated last time
  @apiSuccess {String}   forked_from         Parent ingredient ID, if it was forked
  @apiSuccess {Boolean}  ready_to_eat        Is ingredient ready to be eaten without cooking?
  @apiSuccess {Object[]} measures            List of ingredient measures
  @apiSuccess {Number}   measures.qty        Measure quantity
  @apiSuccess {Number}   measures.eqv        Measure equivalent in grams
  @apiSuccess {String}   measures.label      Measure label
  @apiSuccess {Hash[]}   measures.nutrients  Hash of nutrients values for this measure

  @apiError NotFound Ingredient with requested ID was not found
=end
  get '/:id' do
    get_entity_from(IngredientRepository)
  end

=begin
  @api {post} /ingredients Create new ingredient
  @apiVersion 0.1.0
  @apiName IngredientsCreate
  @apiGroup Ingredients
  @apiDescription Create new ingredient. This action can only be performed by authenticated user.
  @apiPermission authenticated user
  @apiSampleRequest off

  @apiHeader {String} authorization JWT (JSON Web Token)
  @apiHeaderExample Example auth header:
  authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ0.ekJkYZRhIjp7InVzZXJfaWQiOiJBVTlfM09YenNPZ0FZYjVDUFBaNyJ9LCJleHAiOjE0NzA5MTE4NjAsIm5iZiI6MTQ3MDgyNTE2MH9.yZ8oQLsobrzfEWPVZXlILCcDjLj6IUhDveNoO072zyc

  @apiParam {String}   name                Ingredient name
  @apiParam {String}   group               Ingredient group (Fruits, Vegetables, Grains, etc)
  @apiParam {Boolean}  [generic]           Is ingredient generic?
  @apiParam {String}   [image_crop]        Ingredient image as base64 encoded data-uri
  @apiParam {String}   [forked_from]       Parent ingredient ID, if it was forked
  @apiParam {Boolean}  [ready_to_eat]      Is ingredient ready to be eaten without cooking?
  @apiParam {Object[]} measures            List of ingredient measures
  @apiParam {Number}   measures.qty        Measure quantity
  @apiParam {Number}   measures.eqv        Measure equivalent in grams
  @apiParam {String}   measures.label      Measure label
  @apiParam {Hash[]}   measures.nutrients  Hash of nutrients values for this measure

  @apiError (Error 400) InvalidRequest          Request payload is missing or could not be parsed
  @apiError (Error 401) AuthenticationRequired  Request was made without authentication
  @apiError (Error 422) ValidationError         One of the required fields is missing or has wrong type

  @apiSuccess (Success 201) {String} id Unique ID of newly created ingredient
=end
  post '/' do
    create_entity_in(IngredientRepository)
  end


=begin
  @api {put} /ingredients/:id Update ingredient
  @apiVersion 0.1.0
  @apiName IngredientsUpdate
  @apiGroup Ingredients
  @apiDescription Update ingredient. This action can be performed only by authenticated owner of the ingredient.
  @apiPermission owner
  @apiSampleRequest off

  @apiHeader {String} authorization JWT (JSON Web Token)
  @apiHeaderExample Example auth header:
  authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ0.ekJkYZRhIjp7InVzZXJfaWQiOiJBVTlfM09YenNPZ0FZYjVDUFBaNyJ9LCJleHAiOjE0NzA5MTE4NjAsIm5iZiI6MTQ3MDgyNTE2MH9.yZ8oQLsobrzfEWPVZXlILCcDjLj6IUhDveNoO072zyc

  @apiParam {String}   id                    Ingredient unique ID
  @apiParam {String}   [name]                Ingredient name
  @apiParam {String}   [group                Ingredient group (Fruits, Vegetables, Grains, etc)
  @apiParam {Boolean}  [generic]             Is ingredient generic?
  @apiParam {String}   [image_crop]          Ingredient image as base64 encoded data-uri
  @apiParam {String}   [forked_from]         Parent ingredient ID, if it was forked
  @apiParam {Boolean}  [ready_to_eat]        Is ingredient ready to be eaten without cooking?
  @apiParam {Object[]} [measures]            List of ingredient measures
  @apiParam {Number}   [measures.qty]        Measure quantity
  @apiParam {Number}   [measures.eqv]        Measure equivalent in grams
  @apiParam {String}   [measures.label]      Measure label
  @apiParam {Hash[]}   [measures.nutrients]  Hash of nutrients values for this measure

  @apiError (Error 400) InvalidRequest          Request payload is missing or could not be parsed
  @apiError (Error 401) AuthenticationRequired  Request was made without authentication or not by ingredient owner
  @apiError (Error 404) NotFound                Ingredient with given ID was not found

  @apiSuccess (Success 200) {String} id Unique ID of updated ingredient
=end
  put '/:id' do
    update_entity_in(IngredientRepository)
  end

  options '/*' do
    200
  end

  private
  def search
    if params[:filter_by] == 'id'
      return IngredientRepository.find_by_ids(params[:filter_value].split(","))
    end

    search_entities_in(IngredientRepository)
  end
end

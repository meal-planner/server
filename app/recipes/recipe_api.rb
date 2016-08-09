# /recipes API REST endpoint
class RecipeAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::Entity,
    MealPlanner::Helper::Auth

  before do
    content_type :json
    params.each { |key, val| params[key] = nil if val && val.empty? }
  end

  after do
    response.body = response.body.to_json
  end

=begin
  @api {get} /recipes List or search recipes
  @apiVersion 0.1.0
  @apiName RecipesList
  @apiGroup Recipes
  @apiDescription
  Recipes list can be used to retrieve a list of all recipes,
  filtered recipes or to perform full text search on the recipes.

  @apiExample {curl} Search in specific dish type:
  curl -i "https://api.meal-planner.org/recipes?query=bacon&filter_by=dish_type&filter_value=Breakfast"

  @apiParam {String} [query]         Full text search query
  @apiParam {String = 'owner_id','dish_type','cuisine','key_ingredient','diet'} [filter_by] Filter attribute name
  @apiParam {String} [filter_value]  Filter value
  @apiParam {Number} [start]         Initial offset
  @apiParam {Number} [size=12]       Number of items to return
  @apiParam {String} [sort]          Sort by attribute name

  @apiSuccess {Number}   total                            Total number of recipes matching the query
  @apiSuccess {Object[]} items                            List of recipes
  @apiSuccess {String}   items.id                         Recipe unique ID
  @apiSuccess {String}   items.name                       Recipe name
  @apiSuccess {String[]} items.steps                      List of cooking steps
  @apiSuccess {Number}   items.servings                   Number of servings in this recipe
  @apiSuccess {String}   items.owner_id                   Ingredient owner unique ID
  @apiSuccess {String}   items.image_url                  Ingredient image URL (relative to content origin)
  @apiSuccess {Date}     items.created_at                 Date when ingredient was created
  @apiSuccess {Date}     items.updated_at                 Date when ingredient was updated last time
  @apiSuccess {Number}   items.time_to_cook               Time to cook in minutes
  @apiSuccess {String[]} items.key_ingredient             Recipe key ingredient (Pork, Vegetables, Eggs, etc)
  @apiSuccess {String}   items.dish_type                  Recipe dish type (Main dish, Breakfast, Salad, etc)
  @apiSuccess {String[]} items.cuisine                    Recipe cuisine (American, Chinese, Italian, etc)
  @apiSuccess {String[]} items.diet                       Recipe diet (Vegetarian, Vegan, Mediterranean, etc)
  @apiSuccess {Hash}     items.nutrients                  Hash of total recipe nutrients
  @apiSuccess {Object[]} items.ingredients                List of recipe ingredients
  @apiSuccess {String}   items.ingredients.id             Ingredient unique ID
  @apiSuccess {String}   items.ingredients.measure        Selected ingredient measure
  @apiSuccess {Number}   items.ingredients.measure_amount Selected ingredient amount
  @apiSuccess {Number}   items.ingredients.position       Ingredient position in list
=end
  get '/' do
    result = search_entities_in(RecipeRepository)
    {
      total: result.response.hits.total,
      items: result.to_a
    }
  end


=begin
  @api {get} /recipes/:id Get recipe information
  @apiVersion 0.1.0
  @apiName RecipesItem
  @apiGroup Recipes
  @apiDescription
  Retrieve single recipe by its unique ID.

  @apiExample {curl} Example:
  curl -i "https://api.meal-planner.org/recipes/AU5VNS1d4L1exazeM9Lc"

  @apiParam {String} id Recipe unique ID

  @apiSuccess {String}   id                         Recipe unique ID
  @apiSuccess {String}   name                       Recipe name
  @apiSuccess {String[]} steps                      List of cooking steps
  @apiSuccess {Number}   servings                   Number of servings in this recipe
  @apiSuccess {String}   can_edit                   Only returned if request is made by owner
  @apiSuccess {String}   image_url                  Ingredient image URL (relative to content origin)
  @apiSuccess {Date}     created_at                 Date when ingredient was created
  @apiSuccess {Date}     updated_at                 Date when ingredient was updated last time
  @apiSuccess {Number}   time_to_cook               Time to cook in minutes
  @apiSuccess {String[]} key_ingredient             Recipe key ingredient (Pork, Vegetables, Eggs, etc)
  @apiSuccess {String}   dish_type                  Recipe dish type (Main dish, Breakfast, Salad, etc)
  @apiSuccess {String[]} cuisine                    Recipe cuisine (American, Chinese, Italian, etc)
  @apiSuccess {String[]} diet                       Recipe diet (Vegetarian, Vegan, Mediterranean, etc)
  @apiSuccess {Hash}     nutrients                  Hash of total recipe nutrients
  @apiSuccess {Object[]} ingredients                List of recipe ingredients
  @apiSuccess {String}   ingredients.id             Ingredient unique ID
  @apiSuccess {String}   ingredients.measure        Selected ingredient measure
  @apiSuccess {Number}   ingredients.measure_amount Selected ingredient amount
  @apiSuccess {Number}   ingredients.position       Ingredient position in list

  @apiError NotFound Recipe with requested ID was not found
=end
  get '/:id' do
    get_entity_from(RecipeRepository)
  end

=begin
  @api {post} /recipes Create new recipe
  @apiVersion 0.1.0
  @apiName RecipesCreate
  @apiGroup Recipes
  @apiDescription Create new recipe. This action can only be performed by authenticated user.
  @apiPermission authenticated user
  @apiSampleRequest off

  @apiParam {String}   name                       Recipe name
  @apiParam {String[]} steps                      List of cooking steps
  @apiParam {Number}   servings                   Number of servings in this recipe
  @apiParam {String}   dish_type                  Recipe dish type (Main dish, Breakfast, Salad, etc)
  @apiParam {Number}   time_to_cook               Time to cook in minutes
  @apiParam {String}   [image_crop]               Ingredient image as base64 encoded data-uri
  @apiParam {String[]} [key_ingredient]           Recipe key ingredient (Pork, Vegetables, Eggs, etc)
  @apiParam {String[]} [cuisine]                  Recipe cuisine (American, Chinese, Italian, etc)
  @apiParam {String[]} [diet]                     Recipe diet (Vegetarian, Vegan, Mediterranean, etc)
  @apiParam {Hash}     nutrients                  Hash of total recipe nutrients
  @apiParam {Object[]} ingredients                List of recipe ingredients
  @apiParam {String}   ingredients.id             Ingredient unique ID
  @apiParam {String}   ingredients.measure        Selected ingredient measure
  @apiParam {Number}   ingredients.measure_amount Selected ingredient amount
  @apiParam {Number}   ingredients.position       Ingredient position in list

  @apiError (Error 400) InvalidRequest          Request payload is missing or could not be parsed
  @apiError (Error 401) AuthenticationRequired  Request was made without authentication
  @apiError (Error 422) ValidationError         One of the required fields is missing or has wrong type

  @apiSuccess (Success 201) {String} id Unique ID of newly created recipe
=end
  post '/' do
    create_entity_in(RecipeRepository)
  end

=begin
  @api {put} /recipes/:id Update recipe
  @apiVersion 0.1.0
  @apiName RecipesUpdate
  @apiGroup Recipes
  @apiDescription Update recipe. This action can be performed only by authenticated owner of the recipe.
  @apiPermission owner
  @apiSampleRequest off

  @apiParam {String}   id                           Recipe unique ID
  @apiParam {String}   [name]                       Recipe name
  @apiParam {String[]} [steps]                      List of cooking steps
  @apiParam {Number}   [servings]                   Number of servings in this recipe
  @apiParam {String}   [dish_type]                  Recipe dish type (Main dish, Breakfast, Salad, etc)
  @apiParam {Number}   [time_to_cook]               Time to cook in minutes
  @apiParam {String}   [image_crop]                 Ingredient image as base64 encoded data-uri
  @apiParam {String[]} [key_ingredient]             Recipe key ingredient (Pork, Vegetables, Eggs, etc)
  @apiParam {String[]} [cuisine]                    Recipe cuisine (American, Chinese, Italian, etc)
  @apiParam {String[]} [diet]                       Recipe diet (Vegetarian, Vegan, Mediterranean, etc)
  @apiParam {Hash}     [nutrients]                  Hash of total recipe nutrients
  @apiParam {Object[]} [ingredients]                List of recipe ingredients
  @apiParam {String}   [ingredients.id]             Ingredient unique ID
  @apiParam {String}   [ingredients.measure]        Selected ingredient measure
  @apiParam {Number}   [ingredients.measure_amount] Selected ingredient amount
  @apiParam {Number}   [ingredients.position]       Ingredient position in list

  @apiError (Error 400) InvalidRequest          Request payload is missing or could not be parsed
  @apiError (Error 401) AuthenticationRequired  Request was made without authentication or not by recipe owner
  @apiError (Error 404) NotFound                Recipe with given ID was not found
  @apiError (Error 422) ValidationError         Validation failed, see error message for more details

  @apiSuccess (Success 201) {String} id Unique ID of updated recipe
=end
  put '/:id' do
    update_entity_in(RecipeRepository)
  end
end

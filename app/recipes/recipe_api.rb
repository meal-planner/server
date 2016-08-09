# /recipes API REST endpoint
class RecipeAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::Entity,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  after do
    response.body = response.body.to_json
  end

  get '/' do
    result = search_entities_in(RecipeRepository)
    {
      total: result.response.hits.total,
      items: result.to_a
    }
  end

  get '/:id' do
    get_entity_from(RecipeRepository)
  end

  post '/' do
    create_entity_in(RecipeRepository)
  end

  put '/:id' do
    update_entity_in(RecipeRepository)
  end
end

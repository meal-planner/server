require 'sinatra/base'
require 'active_support/core_ext/hash/slice'
require_relative 'recipe'

class RecipeAPI < Sinatra::Base

  helpers do
    def parse_request
      body = request.body.read
      halt 400, {error: 'Payload is missing.'}.to_json if body.empty?

      begin
        request = JSON.parse(body).extract!('name', 'time_to_cook', 'steps', 'ingredients', 'nutrients')
        ingredients = []
        Array(request['ingredients']).each do |ingredient_request|
          ingredient = ingredient_request.extract!('id', 'name', 'short_name', 'group', 'measure', 'measure_amount')
          ingredients.push ingredient
        end
        request['ingredients'] = ingredients
        nutrients = {}
        Hash(request['nutrients']).each_key do |nutrient_name|
          nutrients[nutrient_name] = request['nutrients'][nutrient_name].to_f
        end
        request['nutrients'] = nutrients
      rescue
        halt 400, {error: 'Request could not be processed.'}.to_json
      end
      request
    end

    def load_recipe
      begin
        Recipe.find params[:id]
      rescue Elasticsearch::Persistence::Repository::DocumentNotFound
        halt 404, {error: 'Recipe not found.'}.to_json
      end
    end
  end

  get '/' do
    query = params[:query]
    if query
      results = Recipe.search query: {match: {name: query}}, size: 18
    else
      results = Recipe.search query: {match_all: {}}, sort: {created_at: {order: 'desc'}}, size: 6
    end
    results.to_json
  end

  get '/:id' do
    load_recipe.to_json
  end

  post '/' do
    recipe = Recipe.new parse_request

    halt 422, recipe.errors.to_json unless recipe.valid?

    recipe.save
    status 201
    recipe.to_json
  end

  put '/:id' do
    recipe = load_recipe
    request = parse_request
    recipe[:name] = request['name']
    recipe[:time_to_cook] = request['time_to_cook']
    recipe[:ingredients] = request['ingredients']
    recipe[:nutrients] = request['nutrients']
    recipe[:steps] = request['steps']
    recipe.save
    halt 200
  end
end
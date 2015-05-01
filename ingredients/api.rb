require 'sinatra/base'
require 'active_support/core_ext/hash/slice'
require_relative 'ingredient'

class IngredientAPI < Sinatra::Base

  helpers do
    def parse_request
      body = request.body.read
      halt 400, {error: 'Payload is missing.'}.to_json if body.empty?
      begin
        request = JSON.parse(body).extract!('name', 'short_name', 'group', 'nutrients')
        nutrients = {}
        request['nutrients'].each_key do |nutrient_name|
          nutrient = request['nutrients'][nutrient_name].extract!('unit', 'group', 'measures')
          measures = []
          if nutrient['measures']
            nutrient['measures'].each do |measure|
              measure = measure.extract!('qty', 'label', 'eqv', 'value')
              measure['value'] = measure['value'].to_f
              measures.push measure
            end
          end
          nutrient['measures'] = measures
          nutrients[nutrient_name] = nutrient
        end
        request['nutrients'] = nutrients
      rescue
        halt 400, {error: 'Request could not be processed.'}.to_json
      end
      request
    end

    def load_ingredient
      begin
        Ingredient.find params[:id]
      rescue Elasticsearch::Persistence::Repository::DocumentNotFound
        halt 404, {error: 'Ingredient not found.'}.to_json
      end
    end
  end

  get '/' do
    query = params[:query]
    if query
      results = Ingredient.search query: {multi_match: {query: query, fields: %w(short_name^2 name)}}, size: 18
    else
      results = Ingredient.search query: {match_all: {}}, sort: {created_at: {order: 'desc'}}, size: 6
    end
    results.to_json
  end

  get '/:id' do
    load_ingredient.to_json
  end

  post '/' do
    ingredient = Ingredient.new parse_request

    halt 422, ingredient.errors.to_json unless ingredient.valid?

    ingredient.save
    status 201
    ingredient.to_json
  end

  put '/:id' do
    ingredient = load_ingredient
    request = parse_request
    ingredient[:name] = request['name']
    ingredient[:short_name] = request['short_name']
    ingredient[:group] = request['group']
    ingredient[:nutrients] = request['nutrients']
    ingredient.save
    halt 200
  end

  delete '/:id' do
    load_ingredient.destroy
  end
end
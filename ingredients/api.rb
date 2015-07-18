require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash/slice'
require_relative 'ingredient'

class IngredientAPI < Sinatra::Base

  helpers do
    def parse_request
      body = request.body.read
      halt 400, {error: 'Payload is missing.'}.to_json if body.empty?
      begin
        attributes = Ingredient.attribute_set.map {|attr| attr.name.to_s}
        request = JSON.parse(body).extract!(*attributes)
        measures = []
        Array(request['measures']).each do |measure|
          measure = measure.extract!('qty', 'label', 'eqv', 'value', 'nutrients')
          nutrients = {}
          Hash(measure['nutrients']).each_key do |nutrient|
            nutrients[nutrient] = measure['nutrients'][nutrient].to_f
          end
          measure['nutrients'] = nutrients
          measures.push measure
        end
        halt 400, {error: 'Missing required parameter: measures.'} if measures.empty?
        request['measures'] = measures
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
    Ingredient.attribute_set.each do |attr|
      ingredient[attr.name] = request[attr.name.to_s] unless request[attr.name.to_s].nil?
    end
    ingredient.save
    halt 200
  end

  delete '/:id' do
    load_ingredient.destroy
  end
end
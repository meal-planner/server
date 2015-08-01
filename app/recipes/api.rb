require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash/slice'
require_relative 'recipe'

class RecipeAPI < Sinatra::Base

  helpers do
    def parse_request
      body = request.body.read
      halt 400, {error: 'Payload is missing.'}.to_json if body.empty?

      begin
        attributes = Recipe.attribute_set.map { |attr| attr.name.to_s }
        request = JSON.parse(body).extract!(*attributes)
        Array(request['ingredients']).map! do |ingredient|
          ingredient.extract!('id', 'name', 'short_name', 'group', 'measure', 'measure_amount')
        end
        Hash(request['nutrients']).each_key do |name|
          request['nutrients'][name] = request['nutrients'][name].to_f
        end
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
      filter_by = params[:filter_by]
      filter_value = params[:filter_value]
      if filter_by && filter_by.length > 0 && filter_value.length > 0
        filter = {}
        filter[filter_by] = filter_value
        query = {match_phrase: filter}
      else
        query = {match_all: {}}
      end
      results = Recipe.search query: query, sort: {created_at: {order: 'desc'}}, size: 6
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
    Recipe.attribute_set.each do |attr|
      recipe[attr.name] = request[attr.name.to_s] unless request[attr.name.to_s].nil?
    end
    recipe.save
    halt 200
  end
end
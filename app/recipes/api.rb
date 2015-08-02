require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash/slice'
require_relative 'recipe'
require_relative '../api_helpers'

class RecipeAPI < Sinatra::Base

  helpers ApiHelpers

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
    load_entity(Recipe).to_json
  end

  post '/' do
    create_entity Recipe
  end

  put '/:id' do
    update_entity Recipe
  end
end
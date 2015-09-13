require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash/slice'
require_relative 'recipe'
require_relative '../api_helpers'

class RecipeAPI < Sinatra::Base

  helpers ApiHelpers

  get '/' do
    query = {
        query: {
            filtered: {}
        },
        from: params[:start] || 0,
        size: params[:size] || 12
    }
    if params[:filter_by].present?
      query[:query][:filtered][:filter] = {term: {params[:filter_by] => params[:filter_value]}}
    end
    query[:query][:filtered][:query] = {match: {name: params[:query]}} if params[:query].present?

    Recipe.search(query).to_json
  end

  get '/:id' do
    get_entity(Recipe).to_json
  end

  post '/' do
    create_entity Recipe
  end

  put '/:id' do
    update_entity Recipe
  end
end
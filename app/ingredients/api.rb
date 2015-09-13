require 'sinatra/base'
require 'newrelic_rpm'
require_relative 'ingredient'
require_relative '../api_helpers'

class IngredientAPI < Sinatra::Base

  helpers ApiHelpers

  get '/' do
    query = {
        query: {
            filtered: {}
        },
        from: params[:start] || 0,
        size: params[:size] || 12
    }
    query[:query][:filtered][:filter] = {term: {group: params[:group]}} if params[:group].present?
    query[:query][:filtered][:query] = {match: {name: params[:query]}} if params[:query].present?

    Ingredient.search(query).to_json
  end

  get '/:id' do
    get_entity(Ingredient).to_json
  end

  post '/' do
    create_entity Ingredient
  end

  put '/:id' do
    update_entity Ingredient
  end

  delete '/:id' do
    load_entity(Ingredient).destroy
  end
end
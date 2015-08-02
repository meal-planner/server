require 'sinatra/base'
require 'newrelic_rpm'
require_relative 'ingredient'
require_relative '../api_helpers'

class IngredientAPI < Sinatra::Base

  helpers ApiHelpers

  get '/' do
    query = params[:query]
    if query
      results = Ingredient.search query: {multi_match: {query: query, fields: %w(name^2 description)}}, sort: {generic: {order: 'desc'}}, size: 18
    else
      group = params[:group]
      if group
        query = {match: {group: group}}
      else
        query = {match_all: {}}
      end
      results = Ingredient.search query: query, sort: {generic: {order: 'desc'}, created_at: {order: 'desc'}}, size: 8
    end
    results.to_json
  end

  get '/:id' do
    load_entity(Ingredient).to_json
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
require 'sinatra/base'
require_relative 'recipe'

class RecipeAPI < Sinatra::Base
  get '/' do
    recipes = []
    recipes.to_json
  end
end
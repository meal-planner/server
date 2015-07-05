require 'sinatra/base'
require_relative 'ingredients/api'
require_relative 'recipes/api'

map('/api/ingredients') { run IngredientAPI }
map('/api/recipes') { run RecipeAPI }

require 'sinatra/base'
require_relative '../ingredients/api'
require_relative '../recipes/api'

map('/ingredients') { run IngredientAPI }
map('/recipes') { run RecipeAPI }

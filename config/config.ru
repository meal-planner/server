require 'sinatra/base'
require_relative '../app/ingredients/api'
require_relative '../app/recipes/api'

map('/ingredients') { run IngredientAPI }
map('/recipes') { run RecipeAPI }

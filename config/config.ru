require 'sinatra/base'
require 'dotenv'
require_relative '../app/ingredients/api'
require_relative '../app/recipes/api'
require_relative '../app/users/auth_api'
require_relative '../app/users/user_api'

Dotenv.load '../config/.env'

map('/ingredients') { run IngredientAPI }
map('/recipes') { run RecipeAPI }
map('/auth') { run AuthAPI }
map('/user') { run UserAPI }

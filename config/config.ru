require_relative '../meal_planner'

Dotenv.load '.env'

map('/ingredients') { run IngredientAPI }
map('/recipes') { run RecipeAPI }
map('/auth') { run AuthAPI }
map('/user') { run UserAPI }

require 'sinatra'
require_relative 'recipe'

set :port, 4568

get '/' do
  recipes = []
  recipes.to_json
end
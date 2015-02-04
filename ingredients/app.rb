require 'sinatra'
require_relative 'ingredient'

post '/ingredients' do
  body = JSON.parse request.body.read
  ingredient = Ingredient.new body

  if ingredient.valid?
    ingredient.save
    status 201
    ingredient.to_json
  else
    status 422
    ingredient.errors.to_json
  end
end
require 'sinatra'
require_relative 'ingredient'

helpers do
  def input_request
    body = request.body.read
    halt 400, {error: 'Payload missing.'}.to_json if body.empty?

    JSON.parse body
  end
end

post '/ingredients' do
  ingredient = Ingredient.new input_request

  halt 422, ingredient.errors.to_json unless ingredient.valid?

  ingredient.save
  status 201
  ingredient.to_json
end
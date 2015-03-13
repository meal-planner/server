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

get '/ingredients' do
  query = params[:query]
  if query
    results = Ingredient.search query: {prefix: {name: query}}, size: 6
  else
    results = Ingredient.search query: {match_all: {}}, size: 6
  end
  results.to_json
end

delete '/ingredients/:id' do
  begin
    ingredient = Ingredient.find params[:id]
    ingredient.destroy
    halt 200
  rescue Elasticsearch::Persistence::Repository::DocumentNotFound
    halt 404, {error: 'Ingredient not found.'}.to_json
  end
end
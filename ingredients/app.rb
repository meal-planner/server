require 'sinatra'
require_relative 'ingredient'

set :port, 4567

helpers do
  def input_request
    body = request.body.read
    halt 400, {error: 'Payload missing.'}.to_json if body.empty?

    JSON.parse body
  end

  def load_ingredient
    begin
      Ingredient.find params[:id]
    rescue Elasticsearch::Persistence::Repository::DocumentNotFound
      halt 404, {error: 'Ingredient not found.'}.to_json
    end
  end
end

post '/' do
  ingredient = Ingredient.new input_request

  halt 422, ingredient.errors.to_json unless ingredient.valid?

  ingredient.save
  status 201
  ingredient.to_json
end

get '/' do
  query = params[:query]
  if query
    results = Ingredient.search query: {match: {name: query}}, size: 18
  else
    results = Ingredient.search query: {match_all: {}}, sort: {created_at: {order: 'desc'}}, size: 18
  end
  results.to_json
end

get '/:id' do
  load_ingredient.to_json
end

put '/:id' do
  ingredient = load_ingredient
  data = input_request
  ingredient[:name] = data['name']
  ingredient[:group] = data['group']
  ingredient[:nutrients] = data['nutrients']
  ingredient.save
  halt 200
end

delete '/:id' do
  load_ingredient.destroy
end
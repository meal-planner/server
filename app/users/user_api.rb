require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash'
require_relative '../api_helpers'
require_relative 'user'
require_relative 'token'

class UserAPI < Sinatra::Base

  helpers ApiHelpers

  post '/signup' do
    request = parse_request

    user = User.find_by_email(request['email'])
    halt 400, {error: "Email #{request['email']} is already registered."}.to_json if user.present?

    user = User.new request.extract!(*%w{display_name email password})
    halt 422, user.errors.to_json unless user.valid?
    user.save
    user.send_welcome_email

    {token: Token.encode(user.id)}.to_json if user.id
  end

  post '/login' do
    request = parse_request

    user = User.find_by_email(request['email'])
    if user && user.authenticate(request['password'])
      halt 200, {token: Token.encode(user.id)}.to_json
    else
      halt 401, {error: 'Invalid email or password.'}.to_json
    end
  end

  get '/profile' do
    token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
    payload = Token.new(token)
    halt 401, {error: 'Token invalid.'}.to_json unless payload.valid?

    user = User.find(payload.user_id)

    {display_name: user.display_name, email: user.email, avatar: user.avatar}.to_json
  end

end

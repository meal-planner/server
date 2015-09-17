require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash'
require_relative '../api_helpers'
require_relative 'user'

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

    user.login! if user.id
  end

  post '/login' do
    request = parse_request

    user = User.find_by_email(request['email'])
    if user && user.authenticate(request['password'])
      halt 200, user.login!
    else
      halt 401, {error: 'Invalid email or password.'}.to_json
    end
  end

  post '/password_reset_request' do
    request = parse_request
    user = User.find_by_email(request['email'])
    user.send_password_reset unless user.blank?
  end

  post '/reset_password' do
    request = parse_request
    user = User.find_by_password_token(request['token'])
    if user
      user.password = request['new_password']
      halt 200, user.login!
    end
    halt 401, {error: 'Invalid token'}.to_json
  end

  get '/profile' do
    user = authenticated_user
    user_data = {
        id: user.id,
        created_at: DateTime.parse(user.created_at.to_s).to_i,
        display_name: user.display_name,
        email: user.email,
        avatar: user.avatar
    }
    user_data.to_json
  end

end

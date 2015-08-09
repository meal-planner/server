require 'sinatra/base'
require 'newrelic_rpm'
require 'active_support/core_ext/hash'
require_relative '../api_helpers'
require_relative 'user'
require_relative 'token'

class UserAPI < Sinatra::Base

  get '/profile' do
    token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
    payload = Token.new(token)
    halt 401, {error: 'Token invalid.'}.to_json unless payload.valid?

    user = User.find(payload.user_id)

    {display_name: user.display_name, email: user.email, avatar: user.avatar}.to_json
  end

end

require 'active_support/core_ext/object'
require 'sinatra/base'
require 'newrelic_rpm'
require 'koala'
require_relative '../api_helpers'
require_relative 'user'
require_relative 'token'

class AuthAPI < Sinatra::Base

  helpers ApiHelpers

  post '/facebook' do
    request = parse_request
    oauth = Koala::Facebook::OAuth.new(request['clientId'], ENV['FACEBOOK_SECRET'], request['redirectUri'])
    token = oauth.get_access_token(request['code'])

    graph = Koala::Facebook::API.new(token)
    facebook = graph.get_object('me', {fields: 'id,name,email'})
    user = User.search(query: {match: {facebook: facebook['id']}}).first
    if user.blank?
      user = User.new({email: facebook['email'], display_name: facebook['name'], password: SecureRandom.hex})
      picture = graph.get_user_picture_data('me')
      user.avatar = picture['data']['url']
      user.facebook = facebook['id']
      user.save
    end

    {token: Token.encode(user.id)}.to_json
  end

end

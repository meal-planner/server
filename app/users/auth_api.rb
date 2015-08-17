require 'active_support/core_ext/object'
require 'sinatra/base'
require 'newrelic_rpm'
require 'koala'
require 'google/api_client/client_secrets'
require 'google/apis/plus_v1'
require 'twitter_oauth'
require 'redis'
require_relative '../api_helpers'
require_relative 'user'
require_relative 'token'

class AuthAPI < Sinatra::Base

  helpers ApiHelpers

  post '/facebook' do
    request = parse_request
    oauth = Koala::Facebook::OAuth.new(request['clientId'], ENV['FACEBOOK_SECRET'], request['redirectUri'])
    token = oauth.get_access_token(request['code'])
    halt 401, {error: 'Invalid token'}.to_json unless token

    graph = Koala::Facebook::API.new(token)
    facebook = graph.get_object('me', {fields: 'id,name,email'})
    user = User.find_by_oauth(:facebook, facebook['id'])
    if user.blank?
      user = User.find_by_email(facebook['email'])
      if user.blank?
        user = User.new({email: facebook['email'], display_name: facebook['name'], password: SecureRandom.hex})
      end
      picture = graph.get_user_picture_data('me')
      user.avatar = picture['data']['url']
      user.facebook = facebook['id']
      user.save
    end

    {token: Token.encode(user.id)}.to_json
  end

  post '/google' do
    request = parse_request

    client_secrets = Google::APIClient::ClientSecrets.load
    authorization = client_secrets.to_authorization
    authorization.code = request['code']
    authorization.fetch_access_token!
    plus = Google::Apis::PlusV1::PlusService.new
    profile = plus.get_person('me', options: {authorization: authorization})
    email = profile.emails.first.value

    user = User.find_by_oauth(:google, profile.id)
    if user.blank?
      user = User.find_by_email(email)
      if user.blank?
        user = User.new({email: email, display_name: profile.display_name, password: SecureRandom.hex})
      end
      user.avatar = profile.image.url
      user.google = profile.id
      user.save
    end

    {token: Token.encode(user.id)}.to_json
  end

  post '/twitter' do
    request = parse_request
    twitter = TwitterOAuth::Client.new(consumer_key: ENV['TWITTER_KEY'], consumer_secret: ENV['TWITTER_SECRET'])
    redis = Redis.new
    oauth_token = request['oauth_token']

    if oauth_token.blank?
      token = twitter.request_token({oauth_callback: request['redirectUri']})
      redis.set(token.token, token.secret)
      halt 200, {oauth_token: token.token}.to_json
    else
      if oauth_token && request['oauth_verifier']
        access_token = twitter.authorize(oauth_token, redis.get(oauth_token), oauth_verifier: request['oauth_verifier'])
        redis.set(access_token.token, access_token.secret)
        twitter = TwitterOAuth::Client.new(
            consumer_key: ENV['TWITTER_KEY'],
            consumer_secret: ENV['TWITTER_SECRET'],
            token: access_token.token,
            secret: access_token.secret
        )
        profile = twitter.info

        user = User.find_by_oauth(:twitter, profile['id'])
        if user.blank?
          user = User.new({display_name: profile['screen_name'], password: SecureRandom.hex})
          user.avatar = profile['profile_image_url']
          user.twitter = profile['id']
          user.save
        end

        halt 200, {token: Token.encode(user.id)}.to_json
      end
    end
  end

end

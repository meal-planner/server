require 'active_support/core_ext/object'
require 'sinatra/base'
require 'newrelic_rpm'
require 'twitter_oauth'
require 'redis'
require_relative '../api_helpers'
require_relative 'oauth'
require_relative 'user'
require_relative 'token'

class AuthAPI < Sinatra::Base

  helpers ApiHelpers

  %w{facebook google}.each do |provider|
    post "/#{provider}" do
      oauth = "Oauth::#{provider.capitalize}Client".constantize.new
      if oauth.authorized?(parse_request)
        user = User.find_by_oauth(provider, oauth.profile.provider_id)
        if user.blank?
          user = User.find_by_email(oauth.profile.email)
          if user.blank?
            user = User.new
            user.email = oauth.profile.email
            user.password = SecureRandom.hex
          end
        end
        user.display_name = oauth.profile.display_name
        user.avatar = oauth.profile.avatar
        user[provider] = oauth.profile.provider_id
        user.save
        halt 200, {token: Token.encode(user.id)}.to_json
      end
      halt 401, {error: 'Authentication failed'}.to_json
    end
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

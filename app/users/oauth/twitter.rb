module TwitterOAuth
  class Client
    # Override TwitterOAuth gem method to get user email address.
    def info
      get('/account/verify_credentials.json?include_email=true')
    end
  end
end

module Oauth
  class TwitterClient < Oauth::Base
    def initialize
      @redis = Redis.new
      @client = TwitterOAuth::Client.new(consumer_key: ENV['TWITTER_KEY'], consumer_secret: ENV['TWITTER_SECRET'])
    end

    def get_request_token(redirect_uri)
      token = @client.request_token({oauth_callback: redirect_uri})
      @redis.set(token.token, token.secret)
      token.token
    end

    def authorized?(params)
      access_token = @client.authorize(
          params[:oauth_token],
          @redis.get(params[:oauth_token]),
          oauth_verifier: params[:oauth_verifier]
      )
      authorized_client = TwitterOAuth::Client.new(
          consumer_key: ENV['TWITTER_KEY'],
          consumer_secret: ENV['TWITTER_SECRET'],
          token: access_token.token,
          secret: access_token.secret
      )
      twitter = authorized_client.info
      @profile = Oauth::Profile.new
      @profile.provider_id = twitter['id']
      @profile.display_name = twitter['screen_name']
      @profile.email = twitter['email']
      @profile.avatar = twitter['profile_image_url']
    end
  end
end

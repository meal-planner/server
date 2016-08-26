module TwitterOAuth
  # Override TwitterOAuth gem method to get user email address.
  class Client
    def info
      get('/account/verify_credentials.json?include_email=true')
    end
  end
end

module Oauth
  # Twitter OAuth client implementation
  # uses twitter_oauth gem for communication with Twitter API
  # and redis to persist request token secret
  class TwitterClient < Oauth::Base
    def initialize
      @redis  = Redis.new(url: ENV['REDIS_URL'])
      @client = TwitterOAuth::Client.new(
        consumer_key:    ENV['TWITTER_KEY'],
        consumer_secret: ENV['TWITTER_SECRET']
      )
    end

    def get_request_token(redirect_uri)
      token = @client.request_token(oauth_callback: redirect_uri)
      @redis.set(token.token, token.secret)
      token.token
    end

    def authorized?(params)
      access_token          = get_access_token(params)
      authorized_client     = authorize(access_token)
      twitter               = authorized_client.info
      @profile              = Oauth::Profile.new
      @profile.provider     = :twitter
      @profile.provider_id  = twitter['id']
      @profile.display_name = twitter['screen_name']
      @profile.email        = twitter['email']
      @profile.avatar       = twitter['profile_image_url']
    end

    private
    def get_access_token(params)
      @client.authorize(
        params[:oauth_token],
        @redis.get(params[:oauth_token]),
        oauth_verifier: params[:oauth_verifier]
      )
    end

    private
    def authorize(access_token)
      TwitterOAuth::Client.new(
        consumer_key:    ENV['TWITTER_KEY'],
        consumer_secret: ENV['TWITTER_SECRET'],
        token:           access_token.token,
        secret:          access_token.secret
      )
    end
  end
end

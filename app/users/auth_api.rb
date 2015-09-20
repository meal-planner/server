class AuthAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User

  before do
    content_type :json
  end

  post '/facebook' do
    sign_in :facebook
  end

  post '/google' do
    sign_in :google
  end

  post '/twitter' do
    request = parse_request
    oauth_token = request[:oauth_token]

    if oauth_token.blank?
      client = Oauth::TwitterClient.new
      halt 200, {oauth_token: client.get_request_token(request[:redirectUri])}.to_json
    elsif oauth_token && request[:oauth_verifier]
      sign_in(:twitter, request)
    end
  end

  # Sign in with given provider and request.
  def sign_in(provider, request = nil)
    request ||= parse_request
    oauth = "Oauth::#{provider.capitalize}Client".constantize.new
    if oauth.authorized?(request)
      user = UserRepository.find_by_oauth(provider, oauth.profile.provider_id)
      if user.blank?
        user = UserRepository.find_by_email(oauth.profile.email)
        if user.blank?
          user = UserRepository.klass.new
          user.email = oauth.profile.email
          user.password = SecureRandom.hex
          mailer = UserMailer.new user
          mailer.send_welcome_email
        end
      end
      user.display_name = oauth.profile.display_name
      user.avatar = oauth.profile.avatar
      user[provider] = oauth.profile.provider_id
      user.password_token = nil

      UserRepository.persist user
      halt 200, {token: Token.encode(user.id)}.to_json
    end
    halt 401, {error: 'Authentication failed'}.to_json
  end
end

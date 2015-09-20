class AuthAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User,
          MealPlanner::Helper::Auth

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
end

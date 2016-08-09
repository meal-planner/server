# /auth API REST endpoint
# used for OAuth authentication
class AuthAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::User,
    MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  after do
    response.body = response.body.to_json
  end

  post '/facebook' do
    sign_in :facebook
  end

  post '/google' do
    sign_in :google
  end

  post '/twitter' do
    request     = parse_request
    oauth_token = request[:oauth_token]

    if oauth_token.blank?
      client = Oauth::TwitterClient.new
      token  = { oauth_token: client.get_request_token(request[:redirectUri]) }
      halt 200, token
    elsif oauth_token && request[:oauth_verifier]
      sign_in(:twitter, request)
    end
  end
end

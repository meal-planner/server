# /auth API REST endpoint
# used for OAuth authentication
class AuthAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::User,
    MealPlanner::Helper::Auth

  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => ENV['ALLOWED_CORS'],
      'Access-Control-Allow-Methods'      => %w(OPTIONS GET POST),
      'Access-Control-Allow-Headers'      => 'Content-Type'
  end

  after do
    response.body = response.body.to_json
  end

=begin
  @api {post} /auth/facebook Authenticate via Facebook
  @apiVersion 0.1.0
  @apiName OAuthFacebook
  @apiGroup OAuth
  @apiDescription OAuth sign in via Facebook.
  For more information about auth flow see [Satellizer Docs](https://github.com/sahat/satellizer#authentication-flow)
  @apiSampleRequest off

  @apiParam {String} clientId     Facebook App ID
  @apiParam {String} code         Auth code from successful Facebook authorization
  @apiParam {String} redirectUri  Redirect URI, used to verify authorization with Facebook

  @apiSuccess {String} token JWT (JSON Web Token)

  @apiError {String} AuthenticationFailed Could not authenticate with provided request
=end
  post '/facebook' do
    sign_in :facebook
  end

=begin
  @api {post} /auth/google Authenticate via Google+
  @apiVersion 0.1.0
  @apiName OAuthGoogle
  @apiGroup OAuth
  @apiDescription OAuth sign in via Google+.
  For more information about auth flow see [Satellizer Docs](https://github.com/sahat/satellizer#authentication-flow)

  Google Client ID and App URL is stored on server in config/client_secrets.json

  @apiSampleRequest off

  @apiParam {String} code Auth code from successful Google authorization

  @apiSuccess {String} token JWT (JSON Web Token)

  @apiError {String} AuthenticationFailed Could not authenticate with provided request
=end
  post '/google' do
    sign_in :google
  end

=begin
  @api {post} /auth/twitter Authenticate via Twitter
  @apiVersion 0.1.0
  @apiName OAuthTwitter
  @apiGroup OAuth
  @apiDescription OAuth 1.0 sign in via Twitter
  For more information about auth flow see [Satellizer Docs](https://github.com/sahat/satellizer#authentication-flow)

  Twitter uses OAuth 1.0 which means client needs to request `oauth_token` from server before proceeding to Twitter authorization.

  @apiSampleRequest off

  @apiParam {String} [oauth_token] If not provided - new oauth_token will be generated and returned
  @apiParam {String} oauth_verifier Authorized code from Twitter

  @apiSuccess {String} oauth_token If `oauth_token` was not provided in request, new one will be generated and returned
  @apiSuccess {String} token JWT (JSON Web Token)

  @apiError {String} AuthenticationFailed Could not authenticate with provided request
=end
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

  options '/*' do
    200
  end
end

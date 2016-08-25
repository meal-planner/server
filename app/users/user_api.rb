# /users API REST endpoint
class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::User,
    MealPlanner::Helper::Auth

  before do
    content_type :json
    headers 'Access-Control-Allow-Origin' => ENV['ALLOWED_CORS'],
      'Access-Control-Allow-Methods'      => %w(OPTIONS GET POST),
      'Access-Control-Allow-Headers'      => 'Content-Type, Authorization'
  end

  after do
    response.body = response.body.to_json
  end

=begin
  @api {get} /user/profile Get profile information
  @apiVersion 0.1.0
  @apiName UserProfile
  @apiGroup User
  @apiDescription Retrieve authenticated user profile information
  @apiPermission authenticated user
  @apiSampleRequest off
  @apiHeader {String} authorization JWT (JSON Web Token)
  @apiHeaderExample Example auth header:
  authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ0.ekJkYZRhIjp7InVzZXJfaWQiOiJBVTlfM09YenNPZ0FZYjVDUFBaNyJ9LCJleHAiOjE0NzA5MTE4NjAsIm5iZiI6MTQ3MDgyNTE2MH9.yZ8oQLsobrzfEWPVZXlILCcDjLj6IUhDveNoO072zyc

  @apiSuccess {String} id            User unique ID
  @apiSuccess {Date}   created_at    Date when user signed up
  @apiSuccess {String} display_name  User display name
  @apiSuccess {String} email         User email address
  @apiSuccess {String} avatar        User avatar image URL

  @apiError {String} AuthenticationRequired Could not authenticate with provided JWT or token is missing
=end
  get '/profile' do
    profile_data
  end

=begin
  @api {post} /user/signup Create new user
  @apiVersion 0.1.0
  @apiName UserSignup
  @apiGroup User
  @apiDescription Sign up new user and log in if successful.
  Send welcome email via SendGrid.
  @apiSampleRequest off

  @apiParam {String} display_name  User display name
  @apiParam {String} email         User email
  @apiParam {String} password      User password

  @apiSuccess {String} token Authenticated JWT

  @apiError (Error 400) {String} EmailNotUnique    Provided email address is already registered
  @apiError (Error 422) {String} ValidationFailed  One of the required fields is missing or has wrong type
=end
  post '/signup' do
    user = create_user
    respond_with_token(user)
  end

=begin
  @api {post} /user/login Log in existing user
  @apiVersion 0.1.0
  @apiName UserLogin
  @apiGroup User
  @apiDescription Log in existing user and return authenticated JWT.
  @apiSampleRequest off

  @apiParam {String} email     User email
  @apiParam {String} password  User password

  @apiSuccess {String} token Authenticated JWT

  @apiError (Error 401) {String} AuthenticationFailed Invalid email or password
=end
  post '/login' do
    user = authenticate
    respond_with_token(user)
  end

=begin
  @api {post} /user/password_reset_request Request password reset
  @apiVersion 0.1.0
  @apiName UserRequestResetLink
  @apiGroup User
  @apiDescription Request user password reset link. This API does not return anything in response.
  If user with provided email was found - an email with password reset link will be sent to them.
  @apiSampleRequest off

  @apiParam {String} email User email
=end
  post '/password_reset_request' do
    request_password_reset
  end

=begin
  @api {post} /user/reset_password Reset user password
  @apiVersion 0.1.0
  @apiName UserResetPassword
  @apiGroup User
  @apiDescription Reset user password with the token from request email.
  @apiSampleRequest off

  @apiParam {String} token         Secret token from request email
  @apiParam {String} new_password  New user password

  @apiSuccess {String} token Authenticated JWT

  @apiError (Error 401) {String} Invalid secret token
=end
  post '/reset_password' do
    user = reset_user_password
    respond_with_token(user)
  end

  options '/*' do
    200
  end
end

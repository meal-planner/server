# /users API REST endpoint
class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
    MealPlanner::Helper::User,
    MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  after do
    response.body = response.body.to_json
  end

  get '/profile' do
    profile_data
  end

  post '/signup' do
    user = create_user
    respond_with_token(user)
  end

  post '/login' do
    user = authenticate
    respond_with_token(user)
  end

  post '/password_reset_request' do
    request_password_reset
  end

  post '/reset_password' do
    user = reset_user_password
    respond_with_token(user)
  end
end

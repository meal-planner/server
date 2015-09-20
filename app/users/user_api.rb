# /users API REST endpoint
class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  get '/profile' do
    profile_data.to_json
  end

  post '/signup' do
    user = create_user_in UserRepository
    respond_with_token user
  end

  post '/login' do
    user = authenticate_in UserRepository
    respond_with_token user
  end

  post '/password_reset_request' do
    request_password_reset
  end

  post '/reset_password' do
    user = reset_user_password
    respond_with_token user
  end
end

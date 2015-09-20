class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User,
          MealPlanner::Helper::Auth

  before do
    content_type :json
  end

  get '/profile' do
    get_profile_data.to_json
  end

  post '/signup' do
    user = create_user_in UserRepository
    respond_with_token user
  end
end

class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User

  before do
    content_type :json
  end

  post '/signup' do
    request = parse_request

  end

  post '/login' do
    request = parse_request

  end

  post '/password_reset_request' do
    request = parse_request

  end

  post '/reset_password' do
    request = parse_request

  end

  get '/profile' do
    user = authenticated_user
    user_data = {
        id: user.id,
        created_at: DateTime.parse(user.created_at.to_s).to_i,
        display_name: user.display_name,
        email: user.email,
        avatar: user.avatar
    }
    user_data.to_json
  end
end

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
end

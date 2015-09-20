class UserAPI < Sinatra::Base
  helpers MealPlanner::Helper::Request,
          MealPlanner::Helper::User

  before do
    content_type :json
  end

  post '/signup' do
    request = parse_request

    user = UserRepository.find_by_email(request[:email])
    halt 400, {error: "Email #{request[:email]} is already registered."}.to_json if user.present?

    user = UserRepository.klass.new
    user.email = request[:email]
    user.display_name = request[:display_name]
    user.password = request[:password]
    validator = UserValidator.new
    halt 422, validator.errors.to_json unless validator.valid?(user)

    UserRepository.save user
    mailer = UserMailer.new user
    mailer.send_welcome_email

    halt 200, {token: Token.encode(user.id)}.to_json
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

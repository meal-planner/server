module MealPlanner
  module Helper
    module User
      def get_profile_data
        user = authenticated_user
        {
            id: user.id,
            created_at: DateTime.parse(user.created_at.to_s).to_i,
            display_name: user.display_name,
            email: user.email,
            avatar: user.avatar
        }
      end

      def create_user_in(repository)
        request = parse_request

        user = repository.find_by_email(request[:email])
        halt 400, {error: "Email #{request[:email]} is already registered."}.to_json if user.present?

        user = repository.klass.new
        user.attributes = request
        validator = UserValidator.new
        halt 422, validator.errors.to_json unless validator.valid?(user)

        repository.save user
        say_welcome_to user
        user
      end

      # reset password token when successfully authenticated
      def authenticate_in(repository)
        request = parse_request

        user = repository.find_by_email(request[:email])
        authorized = user.present? && user.authenticate(request[:password])
        halt 401, {error: 'Invalid email or password.'}.to_json unless authorized

        user.password_token = nil
        repository.update user
        user
      end

      def reset_user_password
        request = parse_request
        user = UserRepository.find_by_password_token(request[:token])
        halt 401, {error: 'Invalid token'}.to_json unless user.present?

        user.password = request[:new_password]
        user.password_token = nil
        UserRepository.update user
        user
      end

      def request_password_reset
        request = parse_request
        user = UserRepository.find_by_email(request[:email])
        if user.present?
          user.password_token = SecureRandom.hex
          UserRepository.update user
          mailer = UserMailer.new user
          mailer.send_password_reset_email
        end
      end

      def respond_with_token(user)
        halt 200, {token: Token.encode(user.id)}.to_json
      end

      def say_welcome_to(user)
        mailer = UserMailer.new user
        mailer.send_welcome_email
      end
    end
  end
end
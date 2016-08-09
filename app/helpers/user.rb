module MealPlanner
  module Helper
    # User API helper
    module User
      def profile_data
        user = authenticated_user
        {
          id:           user.id,
          created_at:   DateTime.parse(user.created_at.to_s).to_i,
          display_name: user.display_name,
          email:        user.email,
          avatar:       user.avatar
        }
      end

      def create_user
        request = parse_request
        validate_unique_user(UserRepository, request[:email])
        user            = UserRepository.klass.new
        user.attributes = request
        validator       = UserValidator.new
        halt 422, validator.errors unless validator.valid?(user)

        UserRepository.save(user)
        say_welcome_to(user)

        user
      end

      # reset password token when successfully authenticated
      def authenticate
        request = parse_request

        user = UserRepository.find_by_email(request[:email])
        unless user.present? && user.authenticate(request[:password])
          halt 401, { error: 'Invalid email or password.' }
        end

        user.password_token = nil
        UserRepository.update(user)

        user
      end

      def reset_user_password
        request = parse_request
        user    = UserRepository.find_by_password_token(request[:token])
        halt 401, { error: 'Invalid token' } unless user.present?

        user.password       = request[:new_password]
        user.password_token = nil
        UserRepository.update(user)

        user
      end

      def request_password_reset
        request = parse_request
        user    = UserRepository.find_by_email(request[:email])
        return unless user.present?
        user.password_token = SecureRandom.hex
        UserRepository.update(user)
        mailer = UserMailer.new(user)
        mailer.send_password_reset_email
      end

      def respond_with_token(user)
        halt 200, { token: Token.encode(user.id) }
      end

      def say_welcome_to(user)
        mailer = UserMailer.new(user)
        mailer.send_welcome_email
      end

      private
      def validate_unique_user(repository, email)
        return unless repository.find_by_email(email).present?
        halt 400, { error: "Email #{email} is already registered." }
      end
    end
  end
end

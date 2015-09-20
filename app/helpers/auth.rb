module MealPlanner
  module Helper
    module Auth
      def authenticated?
        token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
        token.present?
      end

      def authenticated_user
        begin
          token = request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
          UserRepository.find_by_auth_token(token)
        rescue SecurityError
          halt 401, {error: 'Authentication required'}.to_json
        end
      end

      # Sign in with given provider and request.
      def sign_in(provider, request = nil)
        request ||= parse_request
        oauth = "Oauth::#{provider.capitalize}Client".constantize.new
        halt 401, {error: 'Authentication failed'}.to_json unless oauth.authorized?(request)
        user = oauth_to_user oauth.profile
        UserRepository.persist user
        halt 200, {token: Token.encode(user.id)}.to_json
      end

      private

      # Convert OAuth profile to User
      def oauth_to_user(profile)
        user = UserRepository.find_by_oauth(profile.provider, profile.provider_id)
        if user.blank?
          user = UserRepository.find_by_email(profile.email)
          if user.blank?
            user = UserRepository.klass.new
            user.email = profile.email
            user.password = SecureRandom.hex
            mailer = UserMailer.new user
            mailer.send_welcome_email
          end
        end
        user.display_name = profile.display_name
        user.avatar = profile.avatar
        user[profile.provider] = profile.provider_id
        user.password_token = nil
        user
      end
    end
  end
end
module MealPlanner
  module Helper
    module Auth
      def authenticated?
        auth_token.present?
      end

      def authenticated_user
        begin
          UserRepository.find_by_auth_token(auth_token)
        rescue SecurityError
          halt 401, {error: 'Authentication required'}.to_json
        end
      end

      # Sign in with given OAuth provider and request.
      def sign_in(provider, request = nil)
        request ||= parse_request
        oauth = "Oauth::#{provider.capitalize}Client".constantize.new
        halt 401, {error: 'Authentication failed'}.to_json unless oauth.authorized?(request)
        user = oauth_to_user oauth.profile

        respond_with_token user
      end

      private

      # Convert OAuth profile to User
      def oauth_to_user(profile)
        user = UserRepository.find_by_oauth(profile.provider, profile.provider_id)
        if user.blank?
          user = UserRepository.find_by_email(profile.email)
          if user.blank?
            user = UserRepository.klass.new
            user.password = SecureRandom.hex
            say_welcome_to user
          end
        end
        user.attributes = profile.to_h.except(:provider)
        user.password_token = nil
        UserRepository.persist user

        user
      end

      def auth_token
        request.env['HTTP_AUTHORIZATION'].to_s.split(' ').last
      end
    end
  end
end
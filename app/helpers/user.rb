module MealPlanner
  module Helper
    module User
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
    end
  end
end
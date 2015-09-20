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
    end
  end
end
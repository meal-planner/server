module MealPlanner
  module Repository
    module Model
      module CanBeOwned
        include Virtus.module

        attribute :owner_id, String

        def owner=(user)
          @owner_id = user.id
        end

        def owned_by?(user)
          @owner_id == user.id
        end
      end
    end
  end
end
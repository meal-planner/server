module MealPlanner
  module Repository
    # adds validation to repository objects
    # keep validator class name in @validator
    module Validator
      def validator(validator = nil)
        @validator = validator || @validator
      end

      def validator=(validator)
        @validator = validator
      end
    end
  end
end

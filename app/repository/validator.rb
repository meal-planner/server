module MealPlanner
  module Repository
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
module MealPlanner
  module Repository
    # adds common attributes
    module Model
      def self.included(base)
        base.class_eval do
          attribute :id, String
          attribute :created_at, DateTime, default: -> { Time.now.utc }
          attribute :updated_at, DateTime, default: -> { Time.now.utc }
        end
      end
    end
  end
end

module MealPlanner
  module Repository
    module Model
      def self.included(base)
        base.class_eval do
          attribute :id, String
          attribute :created_at, DateTime, default: lambda { |_,_| Time.now.utc }
          attribute :updated_at, DateTime, default: lambda { |_,_| Time.now.utc }
        end
      end
    end
  end
end
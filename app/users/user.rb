class User
  include Virtus.model
  include MealPlanner::Repository::Model

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password_digest, String
  attribute :password_token, String
  attribute :facebook, String
  attribute :google, String
  attribute :twitter, String
end
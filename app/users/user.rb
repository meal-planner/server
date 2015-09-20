# User entity
class User
  include Virtus.model
  include MealPlanner::Repository::Model
  include ActiveModel::SecurePassword

  has_secure_password validations: false

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password_digest, String
  attribute :password_token, String
  attribute :facebook, String
  attribute :google, String
  attribute :twitter, String
end

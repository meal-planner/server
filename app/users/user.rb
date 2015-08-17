require 'elasticsearch/persistence/model'

class User
  include Elasticsearch::Persistence::Model
  include ActiveModel::SecurePassword

  has_secure_password

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password_digest, String
  attribute :facebook, String
  attribute :google, String
  attribute :twitter, String

  validates :display_name, presence: true

  def self.find_by_email(email)
    self.search({query: {filtered: {filter: {term: {email: email}}}}}).first.presence
  end

  def self.find_by_oauth(provider, id)
    self.search({query: {filtered: {filter: {term: {provider => id}}}}}).first.presence
  end
end
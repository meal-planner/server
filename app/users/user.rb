require 'elasticsearch/persistence/model'

class User
  include Elasticsearch::Persistence::Model

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password, String
  attribute :facebook, String
  attribute :google, String
  attribute :twitter, String

  validates :display_name, presence: true
  validates :password, presence: true
end
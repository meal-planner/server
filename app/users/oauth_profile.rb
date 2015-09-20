module Oauth
  # OAuth profile entity
  # created from OAuth providers response (Facebook, Google etc)
  # and provides unified interface to user profile data
  # from various providers
  class Profile
    include Virtus.model

    attribute :provider, String
    attribute :provider_id, String
    attribute :display_name, String
    attribute :email, String
    attribute :avatar, String
  end
end

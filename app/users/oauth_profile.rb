module Oauth
  class Profile
    include Virtus.model

    attribute :provider_id, String
    attribute :display_name, String
    attribute :email, String
    attribute :avatar, String
  end
end
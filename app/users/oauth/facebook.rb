module Oauth
  # Facebook OAuth client
  class FacebookClient < Oauth::Base
    def authorized?(params)
      oauth = Koala::Facebook::OAuth.new(
        params[:clientId],
        ENV['FACEBOOK_SECRET'],
        params[:redirectUri]
      )
      token = oauth.get_access_token(params[:code])
      return unless token

      @graph   = Koala::Facebook::API.new(token)
      facebook = @graph.get_object('me', fields: 'id, name, email')
      create_profile_from(facebook)
    end

    private

    def create_profile_from(person)
      @profile              = Oauth::Profile.new
      @profile.provider     = :facebook
      @profile.provider_id  = person['id']
      @profile.display_name = person['name']
      @profile.email        = person['email']
      picture               = @graph.get_user_picture_data('me')
      @profile.avatar       = picture['data']['url']
    end
  end
end

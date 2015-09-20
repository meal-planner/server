module Oauth
  class FacebookClient < Oauth::Base
    def authorized?(params)
      oauth = Koala::Facebook::OAuth.new(params[:clientId], ENV['FACEBOOK_SECRET'], params[:redirectUri])
      token = oauth.get_access_token(params[:code])
      return false unless token

      graph = Koala::Facebook::API.new(token)
      facebook = graph.get_object('me', {fields: 'id, name, email'})
      picture = graph.get_user_picture_data('me')
      @profile = Oauth::Profile.new
      @profile.provider_id = facebook['id']
      @profile.display_name = facebook['name']
      @profile.email = facebook['email']
      @profile.avatar = picture['data']['url']
    end
  end
end

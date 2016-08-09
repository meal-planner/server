module Oauth
  # Google+ OAuth client
  class GoogleClient < Base
    def authorized?(params)
      plus   = Google::Apis::PlusV1::PlusService.new
      person = plus.get_person(
        'me',
        options: { authorization: get_authorization(params) }
      )
      create_profile_from(person)
    end

    private

    def get_authorization(params)
      client_secrets     = Google::APIClient::ClientSecrets.load
      authorization      = client_secrets.to_authorization
      authorization.code = params[:code]
      authorization.fetch_access_token!

      authorization
    end

    def create_profile_from(person)
      @profile              = Oauth::Profile.new
      @profile.provider     = :google
      @profile.provider_id  = person.id
      @profile.display_name = person.display_name
      @profile.email        = person.emails.first.value
      @profile.avatar       = person.image.url
    end
  end
end

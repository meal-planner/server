module Oauth
  class GoogleClient < Base
    def authorized?(params)
      client_secrets = Google::APIClient::ClientSecrets.load
      authorization = client_secrets.to_authorization
      authorization.code = params[:code]
      authorization.fetch_access_token!

      plus = Google::Apis::PlusV1::PlusService.new
      google = plus.get_person('me', options: {authorization: authorization})
      @profile = Oauth::Profile.new
      @profile.provider_id = google.id
      @profile.display_name = google.display_name
      @profile.email = google.emails.first.value
      @profile.avatar = google.image.url
    end
  end
end

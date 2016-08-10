# JSON Web Token, used for user authentication
class Token
  JWT_LEEWAY = 30

  attr_reader :user_id

  def initialize(token)
    options  = {
      algorithm: ENV['JWT_ALG'],
      leeway:    JWT_LEEWAY
    }
    payload = JWT.decode(token, ENV['JWT_SECRET'], true, options).first
    @user_id = payload['data']['user_id']
  rescue JWT::ExpiredSignature
  rescue JWT::ImmatureSignature
  rescue JWT::DecodeError
    fail SecurityError, 'Invalid Token'
  end

  def valid?
    user_id.present?
  end

  def self.encode(user_id)
    JWT.encode(
      {
        data: { user_id: user_id },
        exp:  Time.now.to_i + 24 * 3600, # expire in 24 hours
        nbf:  Time.now.to_i - 5 * 60 # not before claim
      },
      ENV['JWT_SECRET'],
      ENV['JWT_ALG']
    )
  end
end

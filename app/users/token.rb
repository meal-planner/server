# JSON Web Token, used for user authentication
class Token
  JWT_SECRET    = ENV['JWT_SECRET']
  JWT_ALGORITHM = ENV['HS256']

  attr_reader :user_id

  def initialize(token)
    @payload = JWT.decode(token, JWT_SECRET, JWT_ALGORITHM).first
    @user_id = @payload['user_id']
  rescue JWT::DecodeError
    nil
  end

  def valid?
    user_id.present? && Time.now < Time.at(@payload['exp'].to_i)
  end

  def self.encode(user_id)
    JWT.encode(
      {
        user_id: user_id,
        exp:     (DateTime.now + 30).to_i
      },
      JWT_SECRET,
      JWT_ALGORITHM
    )
  end
end

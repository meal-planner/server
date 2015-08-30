require 'elasticsearch/persistence/model'
require 'sendgrid-ruby'
require_relative 'token'

class User
  include Elasticsearch::Persistence::Model
  include ActiveModel::SecurePassword

  has_secure_password

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password_digest, String
  attribute :password_token, String
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

  def self.find_by_password_token(token)
    self.search({query: {filtered: {filter: {term: {password_token: token}}}}}).first.presence
  end

  def self.find_by_auth_token(token)
    payload = Token.new(token)
    raise SecurityError, 'Token invalid.' unless payload.valid?

    self.find(payload.user_id)
  end

  # called after user is logged in (via email-password or social sign in).
  # updates timestamp, removes password-reset token and returns authenticated token
  def login!
    @updated_at = DateTime.now
    @password_token = ''
    save
    {token: Token.encode(id)}.to_json
  end

  def send_welcome_email
    send_email(
        subject: 'Welcome to Meal-Planner.org!',
        template_id: 'f98eacca-1e2f-4e76-bd36-86c4d0dc35da'
    )
  end

  def send_password_reset
    @password_token = SecureRandom.hex
    save
    send_email(
        subject: 'Password reset request',
        template_id: '9b2e2975-7869-44c4-9ef5-8532e57cb79f',
        subs: {'-password_reset_link-' => "#{ENV['CLIENT_URL']}#/reset-password/#{@password_token}"}
    )
  end

  private

  def send_email(subject: nil, template_id: nil, subs: {})
    client = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])
    mail = SendGrid::Mail.new do |m|
      m.to = @email
      m.from = 'robot@meal-planner.org'
      m.from_name = 'Meal Planner'
      m.subject = subject
      m.text = '&nbsp;'
      m.html = '&nbsp;'
    end
    header = Smtpapi::Header.new
    if subs
      subs.each do |k, v|
        header.add_substitution(k, Array(v))
      end
    end
    header.add_filter('templates', 'enable', 1)
    header.add_filter('templates', 'template_id', template_id)
    mail.smtpapi = header
    client.send(mail)
  end
end
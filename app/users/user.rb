require 'elasticsearch/persistence/model'
require 'sendgrid-ruby'

class User
  include Elasticsearch::Persistence::Model
  include ActiveModel::SecurePassword

  has_secure_password

  attribute :display_name, String
  attribute :email, String
  attribute :avatar, String
  attribute :password_digest, String
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

  def send_welcome_email
    client = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])
    mail = SendGrid::Mail.new do |m|
      m.to = @email
      m.from = 'robot@meal-planner.org'
      m.from_name = 'Meal Planner'
      m.subject = 'Welcome to Meal-Planner.org!'
      m.text = '&nbsp;'
      m.html = '&nbsp;'
    end
    header = Smtpapi::Header.new
    header.add_filter('templates', 'enable', 1)
    header.add_filter('templates', 'template_id', 'f98eacca-1e2f-4e76-bd36-86c4d0dc35da')
    mail.smtpapi = header
    client.send(mail)
  end
end
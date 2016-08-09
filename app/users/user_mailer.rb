include SendGrid

# Sends emails to user
class UserMailer
  def initialize(user)
    @user = user
  end

  def send_welcome_email
    send_email(
      subject:     'Welcome to Meal-Planner.org!',
      template_id: 'f98eacca-1e2f-4e76-bd36-86c4d0dc35da'
    )
  end

  def send_password_reset_email
    reset_link = "#{ENV['CLIENT_URL']}#/reset-password/#{@user.password_token}"
    send_email(
      subject:     'Password reset request',
      template_id: '9b2e2975-7869-44c4-9ef5-8532e57cb79f',
      subs:        {
        '-password_reset_link-' => reset_link
      }
    )
  end

  private
  def send_email(subject: nil, template_id: nil, subs: {})
    mail                  = build_mail(subject, template_id)
    mail.personalizations = personalize(subs)

    send_grid = SendGrid::API.new(
      api_key: ENV['SENDGRID_KEY'],
      host:    'https://api.sendgrid.com'
    )
    send_grid.client.mail._('send').post(request_body: mail.to_json)
  end

  private
  def build_mail(subject, template_id)
    mail             = Mail.new
    mail.template_id = template_id
    mail.subject     = subject
    mail.from        = Email.new(
      email: 'robot@meal-planner.org',
      name:  'Meal Planner'
    )
    mail
  end

  private
  def personalize(subs)
    personalization    = Personalization.new
    personalization.to = Email.new(email: @user.email)
    if subs
      subs.each do |k, v|
        personalization.substitutions = Substitution.new(key: k, value: v)
      end
    end
    personalization
  end
end

class UserMailer
  def initialize(user)
    @user = user
  end

  def send_welcome_email
    send_email(
        subject: 'Welcome to Meal-Planner.org!',
        template_id: 'f98eacca-1e2f-4e76-bd36-86c4d0dc35da'
    )
  end

  def send_password_reset_email
    send_email(
        subject: 'Password reset request',
        template_id: '9b2e2975-7869-44c4-9ef5-8532e57cb79f',
        subs: {'-password_reset_link-' => "#{ENV['CLIENT_URL']}#/reset-password/#{@user.password_token}"}
    )
  end

  private

  def send_email(subject: nil, template_id: nil, subs: {})
    client = SendGrid::Client.new(api_user: ENV['SENDGRID_USERNAME'], api_key: ENV['SENDGRID_PASSWORD'])
    mail = SendGrid::Mail.new do |m|
      m.to = @user.email
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
    client.send mail
  end
end
# frozen_string_literal: true

# Send a mail to the user upon successful registration
class SuccessfulRegistrationMailerJob
  include Sidekiq::Job

  def perform(user_id)
    user = User.find(id: user_id)
    mailer = Mailer.new
    # Use i18n
    mailer.send(
      from: App.config.mailer.from,
      to: user.email,
      subject: 'Welcome to Arival',
      content: 'Welcome to Arival. Please login with your email and password'
    )
  end
end

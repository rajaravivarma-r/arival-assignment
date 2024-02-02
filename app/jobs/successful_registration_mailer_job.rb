# frozen_string_literal: true

# Send a mail to the user upon successful registration
class SuccessfulRegistrationMailerJob
  include Sidekiq::Job

  def perform(user_id)
    # TODO: Add code to send mail
  end
end

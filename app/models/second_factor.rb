# frozen_string_literal: true

# Model to handle TOTPs
class SecondFactor < Sequel::Model
  plugin :timestamps, update_on_create: true

  def before_create
    set_unique_otp_secret
  end

  class << self
    def enable_for_user(user)
      create(user_id: user.id, enabled: true)
    end
  end

  private

  def set_unique_otp_secret
    loop do
      otp_secret = ROTP::Base32.random
      existing_entry = SecondFactor.find(otp_secret:)
      if existing_entry.nil?
        self.otp_secret = otp_secret
        break
      end
    end
  end
end

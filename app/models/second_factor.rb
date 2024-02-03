# frozen_string_literal: true

# TODO: Store the otp secret in encrypted format
# Model to handle TOTPs
class SecondFactor < Sequel::Model
  USER_TOTP_ISSUER = "arival-#{App.config.environment}".freeze
  plugin :timestamps, update_on_create: true

  one_to_many :backup_codes

  def before_create
    set_unique_otp_secret
  end

  class << self
    def enable_for_user(user)
      second_factor = create(user_id: user.id, enabled: true)
      BackupCode.generate_for_second_factor(second_factor)
      second_factor
    end
  end

  def enabled?
    enabled
  end

  def disable!
    update(enabled: false)
  end

  def valid_user_otp?(otp)
    totp = ROTP::TOTP.new(otp_secret, issuer: USER_TOTP_ISSUER)

    !!totp.verify(otp.to_s)
  end

  def provisioning_uri
    return nil unless enabled?

    email = User.find(id: user_id).email

    totp = ROTP::TOTP.new(otp_secret, issuer: USER_TOTP_ISSUER)
    totp.provisioning_uri(email)
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

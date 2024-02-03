# frozen_string_literal: true

# TODO: Store the otp secret in encrypted format
# Model to handle TOTPs
class SecondFactor < Sequel::Model
  extend EncryptableAttributes

  encrypts :otp_secret, to: :otp_secret_cipher

  USER_TOTP_ISSUER = "arival-#{App.config.environment}".freeze
  plugin :timestamps, update_on_create: true

  one_to_many :backup_codes

  def before_create
    set_unique_otp_secret
  end

  class << self
    def enable_for_user(user)
      existing = true
      second_factor = find_or_create(user_id: user.id) do |sf|
        existing = false
        sf.enabled = true
      end

      return second_factor if existing && second_factor.enabled?

      if second_factor.disabled?
        second_factor.set_unique_otp_secret
        second_factor.enabled = true
        second_factor.save
      end

      BackupCode.generate_for_second_factor(second_factor)
      second_factor
    end

    def with_otp_secret(otp_secret)
      find(otp_secret_cipher: encrypt_and_sign(otp_secret))
    end
  end

  def enabled?
    enabled
  end

  def disabled?
    !enabled?
  end

  def disable!
    SecondFactor.db.transaction do
      update(enabled: false)
      backup_codes.each(&:destroy)
    end
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

  def set_unique_otp_secret
    self.otp_secret = unique_otp_secret
  end

  private

  def unique_otp_secret
    ROTP::Base32.random
  end
end

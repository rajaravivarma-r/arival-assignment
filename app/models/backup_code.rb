# frozen_string_literal: true

# User model
class BackupCode < Sequel::Model
  extend EncryptableAttributes
  encrypts :code, to: :code_cipher

  DEFAULT_NO_OF_BACKUP_CODES = 10

  plugin :timestamps, update_on_create: true

  many_to_one :second_factor

  def before_create
    self.utilized ||= false
    generate_code
  end

  class << self
    def generate_for_second_factor(
      second_factor,
      count: DEFAULT_NO_OF_BACKUP_CODES
    )
      count.times.map do
        create(second_factor_id: second_factor.id)
      end
    end

    def utilize(second_factor:, code:)
      backup_codes = where(second_factor:, utilized: false)
      matching_backup_code = backup_codes.detect { |bc| bc.code == code }
      return false unless matching_backup_code

      matching_backup_code.utilize!
      matching_backup_code
    end
  end

  def utilize!
    update(utilized: true)
  end

  def utilized?
    utilized
  end

  private

  def generate_code
    self.code = SecureRandom.uuid
  end
end

# frozen_string_literal: true

# User model
class BackupCode < Sequel::Model
  DEFAULT_NO_OF_BACKUP_CODES = 10

  plugin :timestamps, update_on_create: true

  many_to_one :second_factor

  def before_create
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
  end

  private

  def generate_code
    self.code = generate_random_code
  end

  def generate_random_code
    rand(10_000_000..99_999_999).to_s
  end
end

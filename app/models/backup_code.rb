# frozen_string_literal: true

# User model
class BackupCode < Sequel::Model
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
      backup_code = find(second_factor:, code:, utilized: false)
      return false unless backup_code

      backup_code.utilize!
      backup_code
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
    # TODO: Add database constraint => index(second_factor_id, code) to be unique
    loop do
      code = generate_random_code
      existing_entry = BackupCode.find(code:, second_factor_id:)
      if existing_entry.nil?
        self.code = code
        break
      end
    end
  end

  def generate_random_code
    rand(10_000_000..99_999_999).to_s
  end
end

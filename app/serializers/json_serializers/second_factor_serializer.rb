# frozen_string_literal: true

module JsonSerializers
  # Serialize second_factor object and collection of user objects
  class SecondFactorSerializer
    attr_reader :second_factor

    class << self
      def serialize(second_factor)
        new(second_factor).as_json
      end
    end

    def initialize(second_factor)
      @second_factor = second_factor
    end

    def as_json
      {
        id: second_factor.id,
        otp_secret: second_factor.otp_secret,
        enabled: second_factor.enabled,
        created_at: second_factor.created_at,
        updated_at: second_factor.updated_at,
        backup_codes: second_factor.backup_codes.map(&:code).sort
      }
    end
  end
end

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

    def initialize(second_factor, request: nil)
      @second_factor = second_factor
      @request = request
    end

    # rubocop:disable Metrics/AbcSize
    def as_json(attributes = {})
      data = {
        id: second_factor.id,
        otp_secret: second_factor.otp_secret,
        enabled: second_factor.enabled,
        created_at: second_factor.created_at,
        updated_at: second_factor.updated_at,
        backup_codes: second_factor.backup_codes.map(&:code).sort
      }

      if (url = attributes[:qr_code_authenticated_url])
        add_qr_code_details(url, data)
      end
      data
    end
    # rubocop:enable Metrics/AbcSize

    private

    def add_qr_code_details(url, data)
      qr_code = QRCode.new(second_factor.provisioning_uri)
      data[:qr_code] = {
        base64: qr_code.as_base64_encoded,
        url: AuthenticatedUrl.generate(url:, content: qr_code.in_html)
      }
    end
  end
end

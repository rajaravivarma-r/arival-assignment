# frozen_string_literal: true

# Used to handle QR code
class QRCode
  attr_reader :provisioning_uri, :qr

  def initialize(provisioning_uri)
    @provisioning_uri = provisioning_uri
    @qr = RQRCode::QRCode.new(provisioning_uri)
  end

  def in_html
    %(<!DOCTYPE html>
        <html>
          <head>
            <title>QR Code</title>
          </head>
          <body>
            <div>
              <img src="#{as_base64_encoded}" alt="#{provisioning_uri}" />
            </div>
          </body>
        </html>).strip
  end

  def as_base64_encoded
    as_png.to_data_url
  end

  private

  def as_png
    @qr.as_png(
      bit_depth: 1,
      border_modules: 4,
      color_mode: ChunkyPNG::COLOR_GRAYSCALE,
      color: 'black',
      file: nil,
      fill: 'white',
      module_px_size: 6,
      resize_exactly_to: false,
      resize_gte_to: false,
      size: 320
    )
  end
end

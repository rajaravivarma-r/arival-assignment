# frozen_string_literal: true

require 'app_helper'

RSpec.describe SessionToken do
  subject(:session_token) { described_class.new }

  let(:payload) { { email: 'test@example.com' } }

  describe '#encode_to_string' do
    it 'encodes payload to a token string' do
      encoded_token = nil
      allow(JWT).to receive(:encode).and_wrap_original do |original_method, *args, **kwargs, &block|
        encoded_token = original_method.call(*args, **kwargs, &block)
      end
      expect(session_token.encode_to_string(payload:)).to eq(encoded_token)
    end
  end

  describe '#decode_payload' do
    let!(:token) { session_token.encode_to_string(payload:) }

    it 'decodes token string to get payload' do
      expect(session_token.decode_payload(token_string: token).first).to(
        include(payload.transform_keys(&:to_s))
      )
    end
  end
end

# frozen_string_literal: true

require 'app_helper'

describe AuthenticatedUrl do
  let(:url) { '/path/%<code>s' }
  let(:content) { 'Some content' }
  let(:expires_in_seconds) { 3600 }

  describe '.generate' do
    it 'generates a unique URL and stores content in Redis' do
      id = 'unique_id'
      unique_url = '/path/unique_id'

      allow(SecureRandom).to receive(:uuid).and_return(id)
      generated_url = described_class.generate(url:, content:, expires_in_seconds:)

      expect(generated_url).to eq(unique_url)
    end
  end

  describe '.get_content' do
    it 'retrieves content from Redis based on the given ID' do
      id = 'unique_id'
      allow(SecureRandom).to receive(:uuid).and_return(id)
      described_class.generate(url:, content:, expires_in_seconds:)

      retrieved_content = described_class.get_content(id)

      expect(retrieved_content).to eq(content)
    end
  end
end

# frozen_string_literal: true

require 'app_helper'

RSpec.describe SecondFactor do
  let(:user) do
    instance_double(User, id: 1)
  end

  describe '.enable_for_user' do
    it 'creates a new SecondFactor for the user' do
      expect do
        described_class.enable_for_user(user)
      end.to change(described_class, :count).by(1)

      second_factor = described_class.last
      expect(second_factor.user_id).to eq(user.id)
      expect(second_factor.enabled).to be(true)
      expect(second_factor.otp_secret).not_to be_nil
    end
  end

  describe '#before_create' do
    it 'sets a unique OTP secret before creating' do
      allow(ROTP::Base32).to receive(:random).and_return('unique_otp_secret')

      described_class.create(user_id: user.id, enabled: true)

      second_factor = described_class.last
      expect(second_factor.otp_secret).to eq('unique_otp_secret')
    end

    it 'handles setting unique OTP secrets when conflicts occur' do
      allow(ROTP::Base32).to(
        receive(:random).and_return('conflict_otp_secret', 'conflict_otp_secret', 'unique_otp_secret')
      )

      described_class.create(user_id: user.id, enabled: true, otp_secret: 'conflict_otp_secret')

      expect do
        described_class.create(user_id: (user.id + 1), enabled: true)
      end.to change(described_class, :count).by(1)

      second_factor = described_class.last
      expect(second_factor.otp_secret).to eq('unique_otp_secret')
    end
  end
end

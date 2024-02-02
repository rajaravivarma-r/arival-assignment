require 'app_helper'

RSpec.describe SecondFactor do
  let(:user) do
    double('User', id: 1)
  end

  describe '.enable_for_user' do
    it 'creates a new SecondFactor for the user' do
      expect {
        SecondFactor.enable_for_user(user)
      }.to change(SecondFactor, :count).by(1)

      second_factor = SecondFactor.last
      expect(second_factor.user_id).to eq(user.id)
      expect(second_factor.enabled).to eq(true)
      expect(second_factor.otp_secret).not_to be_nil
    end
  end

  describe '#before_create' do
    it 'sets a unique OTP secret before creating' do
      allow(ROTP::Base32).to receive(:random).and_return('unique_otp_secret')

      SecondFactor.create(user_id: user.id, enabled: true)

      second_factor = SecondFactor.last
      expect(second_factor.otp_secret).to eq('unique_otp_secret')
    end

    it 'handles setting unique OTP secrets when conflicts occur' do
      allow(ROTP::Base32).to(
        receive(:random).and_return('conflict_otp_secret', 'conflict_otp_secret', 'unique_otp_secret')
      )

      SecondFactor.create(user_id: user.id, enabled: true, otp_secret: 'conflict_otp_secret')

      expect {
        SecondFactor.create(user_id: (user.id + 1), enabled: true)
      }.to change(SecondFactor, :count).by(1)

      second_factor = SecondFactor.last
      expect(second_factor.otp_secret).to eq('unique_otp_secret')
    end
  end
end

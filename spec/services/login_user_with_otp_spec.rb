# frozen_string_literal: true

require 'app_helper'

RSpec.describe LoginUserWithOtp do
  let(:user) do
    User.create(email: 'test@example.com', password: 'password')
  end

  describe '.call' do
    it 'calls the #call method on a new instance' do
      instance = instance_double(described_class)
      expect(described_class).to receive(:new).and_return(instance)
      expect(instance).to receive(:call)
      described_class.call(verified_user: user, otp: '123456')
    end
  end

  describe '#call' do
    context 'when the OTP is valid' do
      let(:second_factor) { SecondFactor.enable_for_user(user) }
      let(:totp) do
        ROTP::TOTP.new(second_factor.otp_secret, issuer: SecondFactor::USER_TOTP_ISSUER)
      end
      let(:otp) { totp.now }

      it 'returns a successful result with the verified user' do
        service = described_class.new(verified_user: user, otp:)

        result = service.call

        expect(result.success?).to be(true)
        expect(result.value).to eq(user)
      end
    end

    context 'when the OTP is invalid' do
      before { SecondFactor.enable_for_user(user) }

      it 'returns a failure result with an error message' do
        service = described_class.new(verified_user: user, otp: '12345678')

        result = service.call

        expect(result.success).to be(false)
        expect(result.errors.to_h).to eq('otp' => ['invalid otp'])
      end
    end

    context 'when the OTP is nil' do
      before { SecondFactor.enable_for_user(user) }

      it 'returns a failure result with an error message' do
        service = described_class.new(verified_user: user, otp: nil)

        result = service.call

        expect(result.success).to be(false)
        expect(result.errors.to_h).to eq('otp' => ['invalid otp'])
      end
    end

    context 'when the a backup code is passed' do
      let(:second_factor) { SecondFactor.enable_for_user(user) }
      let(:backup_code) { second_factor.backup_codes.first }

      it 'returns a failure result with an error message' do
        service = described_class.new(verified_user: user, otp: backup_code.code)

        result = service.call

        expect(backup_code.reload).to be_utilized
        expect(result.success).to be(true)
        expect(result.value).to eq(user)
      end
    end

    context 'when utilized backup code is passed' do
      let(:second_factor) { SecondFactor.enable_for_user(user) }
      let(:backup_code) { second_factor.backup_codes.first }

      it 'returns a failure result with an error message' do
        backup_code.utilize!
        service = described_class.new(verified_user: user, otp: backup_code.code)

        result = service.call

        expect(result.success).to be(false)
        expect(result.errors.to_h).to eq('otp' => ['invalid otp'])
      end
    end
  end
end

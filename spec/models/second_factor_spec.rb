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
      expect(second_factor.backup_codes).not_to be_empty
    end

    context 'when re-enabling' do
      let!(:second_factor) do
        described_class.create(user_id: user.id, enabled: false)
      end

      it 'creates a new SecondFactor for the user' do
        old_secret = second_factor.otp_secret
        expect(second_factor).not_to be_enabled
        expect(second_factor.backup_codes.size).to eq(0)
        expect do
          described_class.enable_for_user(user)
        end.not_to change(described_class, :count)

        second_factor = described_class.last
        expect(second_factor.user_id).to eq(user.id)
        expect(second_factor).to be_enabled
        expect(second_factor.otp_secret).not_to be_nil
        expect(second_factor.otp_secret).not_to eq(old_secret)
        expect(second_factor.backup_codes).not_to be_empty
      end
    end
  end

  describe '#valid_user_otp?' do
    let(:totp) do
      ROTP::TOTP.new(second_factor.otp_secret, issuer: SecondFactor::USER_TOTP_ISSUER)
    end
    let(:second_factor) { described_class.create(user_id: 1) }

    context 'when the otp is valid' do
      let(:otp) { totp.now }

      it 'returns true' do
        # TODO: May be use Timcop.freeze to make sure the otp does not expire
        expect(second_factor.valid_user_otp?(otp)).to be(true)
      end
    end

    context 'when the otp is not valid' do
      it 'returns false' do
        otp = '5739483'
        expect(second_factor.valid_user_otp?(otp)).to be(false)
      end
    end
  end

  describe '#provisioning_uri' do
    let(:user) { User.create(email: 'test@example.com', password: 'password') }
    let(:second_factor) { described_class.enable_for_user(user) }

    context 'when enabled' do
      it 'returns the provisioning_uri' do
        expect(second_factor.provisioning_uri).not_to be_empty
      end
    end

    context 'when not enabled' do
      before do
        second_factor.disable!
      end

      it 'returns nil' do
        expect(second_factor.provisioning_uri).to be_nil
      end
    end
  end

  describe '#disable!' do
    let(:user) { User.create(email: 'test@example.com', password: 'password') }
    let!(:second_factor) { described_class.enable_for_user(user) }

    it 'disables and removes all associated backup codes' do
      expect(second_factor).to be_enabled
      expect(second_factor.backup_codes.size).to eq(10)
      second_factor.disable!

      expect(second_factor.reload).not_to be_enabled
      expect(second_factor.backup_codes.size).to eq(0)
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

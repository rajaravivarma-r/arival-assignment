# frozen_string_literal: true

require 'app_helper'

RSpec.describe User do
  let(:user_data) { { email: 'test@example.com', password: 'password123' } }
  let(:user) { described_class.create(user_data) }

  describe '#valid_password?' do
    it 'returns true for a valid password' do
      expect(user.valid_password?('password123')).to be true
    end

    it 'returns false for an invalid password' do
      expect(user.valid_password?('wrongpassword')).to be false
    end
  end

  describe '#two_factor_authentication_enabled?' do
    context 'when second_factor is nil' do
      before do
        user.second_factor&.destroy
      end

      it 'returns false' do
        expect(user.two_factor_authentication_enabled?).to be(false)
      end
    end

    context 'when second_factor is enabled' do
      before do
        SecondFactor.enable_for_user(user)
      end

      it 'returns the value of second_factor.enabled?' do
        expect(user.two_factor_authentication_enabled?).to be(true)
      end
    end

    context 'when second_factor is disabled' do
      before do
        second_factor = SecondFactor.enable_for_user(user)
        second_factor.disable!
      end

      it 'returns the value of second_factor.enabled?' do
        expect(user.two_factor_authentication_enabled?).to be(false)
      end
    end
  end

  describe '#password=' do
    it 'sets the password_hash using BCrypt' do
      user.password = 'newpassword'
      expect(BCrypt::Password.new(user.password_hash)).to eq 'newpassword'
    end

    it 'does not set the password_hash if the new password is nil or empty' do
      expect { user.password = nil }.not_to(change(user, :password_hash))
      expect { user.password = '' }.not_to(change(user, :password_hash))
    end
  end
end

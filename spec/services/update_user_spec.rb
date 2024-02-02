# frozen_string_literal: true

require 'app_helper'

RSpec.describe UpdateUser do
  let(:email) { 'user@example.com' }
  let(:password) { 'password123' }
  let(:password_verification) { password }
  let(:new_password) { 'newPassword' }
  let!(:user) do
    RegisterNewUser.call(
      email:, password:, password_verification:
    ).value
  end
  let(:updated_attributes) { { password: new_password } }
  let(:update_user) { described_class.new(user:, updated_attributes:) }

  describe '#call' do
    it 'updates the user successfully' do
      expect(user.valid_password?(password)).to be(true)
      result = update_user.call
      updated_user = User.find(id: user.id)
      expect(result.success?).to be true
      expect(updated_user.valid_password?(new_password)).to be(true)
    end

    context 'when sequel error arises' do
      it 'handles sequel error' do
        allow(user).to receive(:update).and_raise(Sequel::Error)
        result = update_user.call
        expect(result.success?).to be false
        expect(result.value).to be_nil
        expect(result.errors.to_h).to include('user' => ['Could not update user'])
      end
    end

    context 'when database error arises' do
      it 'handles database error' do
        allow(user).to receive(:update).and_raise(PG::NotNullViolation)
        result = update_user.call
        expect(result.success?).to be false
        expect(result.value).to be_nil
        expect(result.errors.to_h).to include('user' => ['Could not update user'])
      end
    end
  end
end

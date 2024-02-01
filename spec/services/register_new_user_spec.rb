require 'app_helper'

RSpec.describe RegisterNewUser do
  let(:email) { 'user@example.com' }
  let(:password) { 'password123' }
  let(:password_verification) { 'password123' }

  describe '.call' do
    it 'creates a new user successfully' do
      expect(User).to receive(:create).with(email: email, password_hash: anything).and_return(User.new)
      result = described_class.call(email: email, password: password, password_verification: password_verification)
      expect(result.success?).to be true
      expect(result.value).to be_a(User)
    end

    it 'handles validation failure' do
      result = described_class.call(email: 'invalidemail', password: password, password_verification: password_verification)
      expect(result.success?).to be false
      expect(result.value).to be_nil
      expect(result.errors.map(&:to_h)).to include('email' => ["has invalid format"])
    end

    it 'handles database error' do
      allow(User).to receive(:create).and_raise(Sequel::Error)
      result = described_class.call(email: email, password: password, password_verification: password_verification)
      expect(result.success?).to be false
      expect(result.value).to be_nil
      expect(result.errors.to_h).to eq('user' => ['Could not create user'])
    end
  end
end

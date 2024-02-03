# frozen_string_literal: true

require 'app_helper'

RSpec.describe BackupCode do
  let(:second_factor) { instance_double(SecondFactor, id: 1) }

  describe '.generate_for_second_factor' do
    context 'when count is given' do
      it 'generates count number of backup codes for a second factor' do
        backup_codes = nil
        expect do
          backup_codes = described_class.generate_for_second_factor(
            second_factor, count: 3
          )
        end.to change(described_class, :count).by(3)

        second_factor_ids = backup_codes.map(&:second_factor_id).uniq
        expect(second_factor_ids).to eq([1])
      end
    end

    context 'when count is not given' do
      it 'generates default backup codes for a second factor' do
        backup_codes = nil
        expect do
          backup_codes = described_class.generate_for_second_factor(second_factor)
        end.to change(described_class, :count).by(described_class::DEFAULT_NO_OF_BACKUP_CODES)

        second_factor_ids = backup_codes.map(&:second_factor_id).uniq
        expect(second_factor_ids).to eq([1])
      end
    end
  end

  describe '.utilize' do
    let(:second_factor) { SecondFactor.create(user_id: 1) }
    let!(:backup_codes) do
      2.times.map do
        described_class.create(second_factor:)
      end
    end

    context 'when an unutilized code is submitted' do
      it 'returns truthy' do
        backup_code = backup_codes.first
        code = backup_code.code
        expect(described_class.utilize(second_factor:, code:)).to be_truthy
      end
    end

    context 'when an utilized code is submitted' do
      it 'returns false' do
        backup_code = backup_codes.first
        code = backup_code.code
        backup_code.utilize!
        expect(described_class.utilize(second_factor:, code:)).to be_falsey
      end
    end

    context 'when an invalid code is submitted' do
      it 'returns false' do
        backup_code = backup_codes.first
        code = "#{backup_code.code}rand"
        expect(described_class.utilize(second_factor:, code:)).to be_falsey
      end
    end
  end

  describe '#before_create' do
    it 'generates a random code before creating' do
      backup_code = described_class.create(second_factor_id: 1)

      expect(backup_code.code.size).to be > 10
    end
  end

  describe '#utilize!' do
    it 'updates utilized to true' do
      backup_code = described_class.create(second_factor_id: 1)
      expect(backup_code).not_to be_utilized
      backup_code.utilize!
      expect(backup_code.reload).to be_utilized
    end
  end

  describe '#utilize?' do
    it 'returns the utilization status' do
      backup_code = described_class.create(second_factor_id: 1)
      expect(backup_code.utilized?).to be(false)
      backup_code.utilize!
      expect(backup_code.utilized?).to be(true)
    end
  end
end

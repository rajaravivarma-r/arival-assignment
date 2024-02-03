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

  describe '#before_create' do
    it 'generates a random code before creating' do
      backup_code = described_class.create(second_factor_id: 1)

      expect(backup_code.code.size).to eq(8)
    end
  end
end

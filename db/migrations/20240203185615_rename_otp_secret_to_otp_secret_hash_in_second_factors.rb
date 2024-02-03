# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:second_factors) do
      rename_column :otp_secret, :otp_secret_cipher
    end
  end
end

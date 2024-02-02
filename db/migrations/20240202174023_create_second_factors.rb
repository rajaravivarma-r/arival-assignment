# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:second_factors) do
      primary_key :id
      Integer :user_id, null: false, index: { unique: true }
      String :otp_secret, null: false, index: { unique: true }
      Bool :enabled, null: false, default: true

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end

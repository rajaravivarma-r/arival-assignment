# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:backup_codes) do
      primary_key :id
      Integer :second_factor_id, null: false
      String :code, null: false, index: { unique: true }
      Bool :utilized, null: false, default: false

      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end

# frozen_string_literal: true

Sequel.migration do
  change do
    alter_table(:backup_codes) do
      rename_column :code, :code_cipher
    end
  end
end

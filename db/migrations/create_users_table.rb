# migration.rb

Sequel.migration do
  change do
    create_table(:users) do
      primary_key :id
      String :email, null: false
      String :password_hash, null: false
      String :password_salt, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end

Sequel.migration do
  change do
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:users) do
      primary_key :id
      String :email, :text=>true, :null=>false
      String :password_hash, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
    end
  end
end

Sequel.migration do
  change do
    create_table(:backup_codes, :ignore_index_errors=>true) do
      primary_key :id
      Integer :second_factor_id, :null=>false
      String :code_cipher, :text=>true, :null=>false
      TrueClass :utilized, :default=>false, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:code_cipher], :name=>:backup_codes_code_index, :unique=>true
    end
    
    create_table(:schema_migrations) do
      String :filename, :text=>true, :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:second_factors, :ignore_index_errors=>true) do
      primary_key :id
      Integer :user_id, :null=>false
      String :otp_secret_cipher, :text=>true, :null=>false
      TrueClass :enabled, :default=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:otp_secret_cipher], :name=>:second_factors_otp_secret_index, :unique=>true
      index [:user_id], :unique=>true
    end
    
    create_table(:users, :ignore_index_errors=>true) do
      primary_key :id
      String :email, :text=>true, :null=>false
      String :password_hash, :text=>true, :null=>false
      DateTime :created_at, :null=>false
      DateTime :updated_at, :null=>false
      
      index [:email], :unique=>true
    end
  end
end

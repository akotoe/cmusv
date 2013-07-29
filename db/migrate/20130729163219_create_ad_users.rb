class CreateAdUsers < ActiveRecord::Migration
  def self.up
    create_table :ad_users do |t|
      t.string :principal_name
      t.datetime :account_expires
      t.string :distinguished_name
      t.string :given_name
      t.string :email
      t.string :objectclass
      t.string :user_account_control
      t.string :sur_name
      t.string :given_name
      t.string :display_name
      t.references :ad_organization_unit

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_users
  end
end

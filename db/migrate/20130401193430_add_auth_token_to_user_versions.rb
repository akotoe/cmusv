class AddAuthTokenToUserVersions < ActiveRecord::Migration
  def self.up
    add_column :user_versions, :auth_token, :string
  end

  def self.down
    remove_column :user_versions, :auth_token
  end
end

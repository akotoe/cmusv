class AddPasswordResetToUserVersions < ActiveRecord::Migration
  def self.up
    add_column :user_versions, :password_reset_token, :string
    add_column :user_versions, :password_reset_sent_at, :datetime
  end

  def self.down
    remove_column :user_versions, :password_reset_sent_at
    remove_column :user_versions, :password_reset_token
  end
end

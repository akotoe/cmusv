class CreateAdGroupMemberships < ActiveRecord::Migration
  def self.up
    create_table :ad_group_memberships do |t|
      t.references :ad_user
      t.references :ad_group

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_group_memberships
  end
end

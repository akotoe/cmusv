class CreateAdOrganizationUnits < ActiveRecord::Migration
  def self.up
    create_table :ad_organization_units do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_organization_units
  end
end

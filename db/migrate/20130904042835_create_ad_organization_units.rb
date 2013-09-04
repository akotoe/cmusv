class CreateAdOrganizationUnits < ActiveRecord::Migration
  def self.up
    create_table :ad_organization_units do |t|
      t.string :distinguishedname
      t.string :objectguid
      t.string :whenchanged

      t.timestamps
    end
  end

  def self.down
    drop_table :ad_organization_units
  end
end


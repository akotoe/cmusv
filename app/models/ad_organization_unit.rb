class AdOrganizationUnit < ActiveRecord::Base
  validates_presence_of :distinguishedname, :whenchanged
end

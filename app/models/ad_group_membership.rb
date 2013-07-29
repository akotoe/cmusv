class AdGroupMembership < ActiveRecord::Base
  belongs_to :ad_user
  belongs_to :ad_group
end

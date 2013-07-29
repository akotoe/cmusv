# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ad_group_membership do
    ad_user nil
    ad_group nil
  end
end

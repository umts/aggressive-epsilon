FactoryGirl.define do
  factory :item_type do
    sequence(:name){ |n| "Item type #{n}" }
  end
end

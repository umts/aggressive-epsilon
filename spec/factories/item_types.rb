FactoryGirl.define do
  factory :item_type do
    sequence(:name) { |n| "Item type #{n}" }
    allowed_keys [:color]
    association :creator, factory: :service
  end
end

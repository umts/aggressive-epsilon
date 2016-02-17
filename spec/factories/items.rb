FactoryGirl.define do
  factory :item do
    sequence(:name) { |n| "Item #{n}" }
    item_type
    allowed_keys [:color]
  end
end

FactoryGirl.define do
  factory :damage_type do
    sequence(:name) { |n| "Damage type #{n}" }
    creator factory: :service
  end
end

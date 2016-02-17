FactoryGirl.define do
  factory :service do
    sequence(:name) { |n| "Service #{n}" }
    sequence(:url) { |n| "https://example#{n}.com" }
  end
end

FactoryGirl.define do
  factory :service do
    sequence(:api_key) { |n| "API key #{n}" }
    sequence(:name) { |n| "Service #{n}" }
    sequence(:url) { |n| "https://example#{n}.com" }
  end
end

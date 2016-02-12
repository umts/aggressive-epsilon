FactoryGirl.define do
  factory :app do
    sequence(:api_key) { |n| "API key #{n}" }
    sequence(:name) { |n| "App #{n}" }
    sequence(:url) { |n| "https://example#{n}.com" }
  end
end

FactoryGirl.define do
  factory :reservation do
    start_datetime Date.yesterday.to_datetime
    end_datetime Date.yesterday.to_datetime + 2.days
    item
    creator factory: :service
  end
end

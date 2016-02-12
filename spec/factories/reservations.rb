FactoryGirl.define do
  factory :reservation do
    start_datetime DateTime.current
    end_datetime DateTime.current
    item
  end
end

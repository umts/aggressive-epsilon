include ReservationHelper

FactoryGirl.define do
  factory :reservation do
    start_datetime default_start_time
    end_datetime default_end_time
    item
    creator factory: :service
  end
end

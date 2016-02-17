FactoryGirl.define do
  factory :reservation do
    start_datetime default_start_time
    end_datetime default_end_time
    item
  end

  trait :starting_in_default_range do
    start_datetime(default_start_time + 1.day)
    end_datetime(default_end_time + 1.day)
  end

  trait :ending_in_default_range do
    start_datetime(default_start_time - 1.day)
    end_datetime(default_end_time - 1.day)
  end

  trait :spanning_default_range do
    start_datetime(default_start_time - 1.day)
    end_datetime(default_end_time + 1.day)
  end

  trait :not_during_default_range do
    start_datetime(default_start_time - 1.week)
    end_datetime(default_start_time - 6.days)
  end
end

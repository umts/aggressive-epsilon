module ReservationHelper
  def default_start_time
    Date.yesterday.to_datetime
  end

  # By default reservations are 2 days in length
  def default_end_time
    default_start_time + 2.days
  end
  
  # https://github.com/thoughtbot/factory_girl/issues/229#issuecomment-2696357
  # Can't define factory traits based dynamically around default start and end
  # times, so we define a helper method instead of that.
  # Based on default reservations being 2 days long, we use the given type
  # to shift the reservation around in the default range as needed.
  def reservation_with_times(type)
    modifiers = case type
                when :starting_in_default_range then [-1, -1]
                when :ending_in_default_range   then [1, 1]
                when :spanning_default_range    then [-1, 1]
                when :not_during_default_range  then [-7, -7]
                end
    create :reservation,
           start_datetime: (default_start_time + modifiers.first.days),
           end_datetime: (default_end_time + modifiers.last.days)
  end
end

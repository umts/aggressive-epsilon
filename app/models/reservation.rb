class Reservation < ActiveRecord::Base
  belongs_to :item
  validates :item,
            :start_datetime,
            :end_datetime,
            presence: true
  validate :start_time_before_end_time

  scope :during, lambda { |start_datetime, end_datetime|
    ranges = [start_datetime, end_datetime] * 3
    # Find all reservations which ARE in the range
    where(<<-query, *ranges)
      (start_datetime between ? and ?) OR
      (end_datetime between ? and ?) OR
      (start_datetime <= ? and end_datetime >= ?)
    query
  }

  private

  def start_time_before_end_time
    if start_datetime >= end_datetime
      column_name = Reservation.human_attribute_name(:end_datetime).downcase
      errors.add :start_datetime, "must be before #{column_name}"
    end
  end
end

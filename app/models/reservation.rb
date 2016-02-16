class Reservation < ActiveRecord::Base
  belongs_to :item
  validates :item,
            :start_datetime,
            :end_datetime,
            presence: true
  validate :start_time_before_end_time

  private

  def start_time_before_end_time
    if start_datetime >= end_datetime
      column_name = Reservation.human_attribute_name(:end_datetime).downcase
      errors.add :start_datetime, "must be before #{column_name}"
    end
  end
end

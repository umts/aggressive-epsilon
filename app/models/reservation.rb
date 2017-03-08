class Reservation < ActiveRecord::Base
  belongs_to :item
  belongs_to :creator, class_name: Service
  delegate :item_type, to: :item
  before_validation -> { self.uuid = SecureRandom.uuid }, on: :create
  validates :item,
            :start_datetime,
            :end_datetime,
            :creator,
            :uuid,
            presence: true
  validates :uuid, uniqueness: true
  validate :start_time_before_end_time

  scope :during, lambda { |start_datetime, end_datetime|
    where 'start_datetime <= ? and end_datetime >= ?',
          end_datetime, start_datetime
  }

  private

  def start_time_before_end_time
    if start_datetime >= end_datetime
      column_name = Reservation.human_attribute_name(:end_datetime).downcase
      errors.add :start_datetime, "must be before #{column_name}"
    end
  end
end

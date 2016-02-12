class Reservation < ActiveRecord::Base
  belongs_to :item
  validates :item,
            :start_datetime,
            :end_datetime,
            presence: true
end

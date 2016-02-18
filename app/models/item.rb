class Item < ActiveRecord::Base
  belongs_to :item_type
  has_many :reservations

  serialize :data, Hash

  validates :item_type,
            :name,
            presence: true

  validates :name, uniqueness: true
  validate :data_allowed_keys

  scope :available_between, lambda { |start_datetime, end_datetime|
    where.not id: reserved_during(start_datetime, end_datetime).pluck(:id)
  }

  scope :reserved_during, lambda { |start_datetime, end_datetime|
    reserved_ids = Reservation.during(start_datetime, end_datetime)
                   .pluck :item_id
    where id: reserved_ids
  }

  def reserve!(start_datetime, end_datetime)
    Reservation.create item_id: id,
                       start_datetime: start_datetime,
                       end_datetime: end_datetime
  end

  private

  def data_allowed_keys
    disallowed_keys = data.keys.map(&:to_sym) - item_type.allowed_keys
    if disallowed_keys.present?
      errors.add :base,
                 "Disallowed #{'key'.pluralize disallowed_keys.count}: " +
                 disallowed_keys.join(', ')
    end
  end
end

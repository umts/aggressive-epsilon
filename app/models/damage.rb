class Damage < ActiveRecord::Base
  belongs_to :damage_type
  belongs_to :item
  delegate :item_type, to: :item
  belongs_to :creator, class_name: Service
  before_validation -> { self.uuid = SecureRandom.uuid }, on: :create

  validates :uuid, uniqueness: true
  validates :damage_issued_reservation_uuid, uniqueness: {scope: :damage_fixed_reservation_uuid}
  validates :uuid,
            :damage_issued_reservation_uuid,
            :damage_fixed_reservation_uuid,
            :item,
            presence: true

  def to_json(*_)
    { uuid: uuid,
      item: item.name,
      damage_type: damage_type.name,
      damage_issued_reservation_uuid: damage_issued_reservation_uuid,
      damage_fixed_reservation_uuid: damage_fixed_reservation_uuid
    }.to_json
  end
end

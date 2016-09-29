FactoryGirl.define do
  factory :damage do
    damage_type { create :damage_type }
    damage_issued_reservation_uuid { (create :reservation).uuid }
    damage_fixed_reservation_uuid { (create :damage_reservation).uuid }
    item
    creator factory: :service
  end
end

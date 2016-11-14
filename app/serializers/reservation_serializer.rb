class ReservationSerializer < ActiveModel::Serializer
  belongs_to :item
  belongs_to :item_type
  attributes :uuid, :start_datetime, :end_datetime

  class ItemSerializer < ActiveModel::Serializer
    attributes :name
  end

  class ItemTypeSerializer < ActiveModel::Serializer
    attributes :name
  end
end

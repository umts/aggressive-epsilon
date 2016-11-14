class ItemSerializer < ActiveModel::Serializer
  belongs_to :item_type
  attributes :uuid, :name, :reservable, :data

  class ItemTypeSerializer < ActiveModel::Serializer
    attributes :uuid
  end
end

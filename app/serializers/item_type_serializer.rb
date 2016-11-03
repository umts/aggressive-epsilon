class ItemTypeSerializer < ActiveModel::Serializer
  has_many :items
  attributes :uuid, :name, :allowed_keys

  class ItemSerializer < ActiveModel::Serializer
    attributes :uuid, :name
  end
end

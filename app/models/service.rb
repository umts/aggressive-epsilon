class Service < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :api_key, :name, :url,
            presence: true, uniqueness: true

  before_validation -> { self.api_key = SecureRandom.hex }, on: :create

  def can_read?(item_type)
    permissions.find_by(item_type: item_type).present?
  end
  alias able_to_read? can_read?

  # When called generically (service.can_write?), this checks whether the
  # service has write permissions to ANY item type (**not** to all item types).
  def can_write_to?(item_type = ItemType.all)
    permissions.find_by(item_type: item_type, write: true).present?
  end
  alias able_to_write_to? can_write_to?
end

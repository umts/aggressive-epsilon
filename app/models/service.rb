class Service < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :api_key, :name, :url,
            presence: true, uniqueness: true

  before_validation -> { self.api_key = SecureRandom.hex }, on: :create

  def can_read?(item_type)
    permissions.find_by(item_type: item_type, read: true).present?
  end

  def can_write?(item_type)
    permissions.find_by(item_type: item_type, write: true).present?
  end
end

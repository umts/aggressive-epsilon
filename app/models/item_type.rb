class ItemType < ActiveRecord::Base
  has_many :items, dependent: :destroy
  has_many :reservations, through: :items
  has_many :permissions, dependent: :destroy

  serialize :allowed_keys, Array
  before_validation -> { self.allowed_keys = allowed_keys.map(&:to_sym) }
  before_validation -> { self.uuid = SecureRandom.uuid}, on: :create
  
  validates :name, :uuid, presence: true
  validates :name, :uuid, uniqueness: true

  default_scope -> { order :name }

  # Randomly picks an item from the available items.
  def find_available(start_datetime, end_datetime)
    items.available_between(start_datetime, end_datetime).sample
  end
end
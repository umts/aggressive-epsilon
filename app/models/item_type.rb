class ItemType < ActiveRecord::Base
  has_many :items
  has_many :reservations, through: :items
  has_many :permissions

  serialize :allowed_keys, Array

  validates :name, :allowed_keys, presence: true
  validates :name, uniqueness: true

  # Randomly picks an item from the available items.
  def find_available(start_datetime, end_datetime)
    items.available_between(start_datetime, end_datetime).sample
  end
end

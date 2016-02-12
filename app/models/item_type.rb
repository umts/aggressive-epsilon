class ItemType < ActiveRecord::Base
  has_many :items
  has_many :permissions

  validates :name, presence: true, uniqueness: true
end

class Item < ActiveRecord::Base
  belongs_to :item_type
  has_many :reservations

  serialize :data, Hash

  validates :item_type,
            :name,
            presence: true

  validates :name, uniqueness: true
end

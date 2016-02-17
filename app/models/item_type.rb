class ItemType < ActiveRecord::Base
  has_many :items
  has_many :permissions

  serialize :allowed_keys, Array

  validates :name, :allowed_keys, presence: true
  validates :name, uniqueness: true

  def find_available(start_datetime, end_datetime)
    # TODO
  end
end

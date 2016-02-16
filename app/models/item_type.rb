class ItemType < ActiveRecord::Base
  has_many :items
  has_many :permissions

  validates :name, presence: true, uniqueness: true

  def find_available start_datetime, end_datetime
    # TODO
  end
end

class ItemType < ActiveRecord::Base
  belongs_to :creator, class_name: Service
  has_many :items, dependent: :destroy
  has_many :reservations, through: :items
  has_many :permissions, dependent: :destroy

  serialize :allowed_keys, Array
  before_validation -> { self.allowed_keys = allowed_keys.map(&:to_sym) }

  validates :name, :creator_id, presence: true
  validates :name, uniqueness: true

  default_scope -> { order :name }

  after_create :add_permission

  # Randomly picks an item from the available items.
  def find_available(start_datetime, end_datetime)
    items.available_between(start_datetime, end_datetime).sample
  end

  def add_permission
    Permission.create(write: true, item_type_id: id,
                      service_id: creator_id) if creator_id
  end
end

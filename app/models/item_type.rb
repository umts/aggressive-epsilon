class ItemType < ActiveRecord::Base
  belongs_to :creator, class_name: Service
  has_many :items, dependent: :destroy
  has_many :reservations, through: :items
  has_many :permissions, dependent: :destroy

  serialize :allowed_keys, Array
  before_validation -> { self.allowed_keys = allowed_keys.map(&:to_sym) }
  before_validation -> { self.uuid = SecureRandom.uuid }, on: :create

  validates :name, :creator, :uuid, presence: true
  validates :name, :uuid, uniqueness: true

  default_scope -> { order :name }

  after_create :add_permission
  
  def to_json(*_)
    { id: uuid,
      name: name
      allowed_keys: allowed_keys
      items: items }.to_json
  end

  # Randomly picks an item from the available items.
  def find_available(start_datetime, end_datetime)
    items.available_between(start_datetime, end_datetime).sample
  end

  def add_permission
    Permission.create(write: true, item_type_id: id,
                      service_id: creator_id)
  end
end

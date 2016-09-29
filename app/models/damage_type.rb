class DamageType < ActiveRecord::Base
  belongs_to :creator, class_name: Service
  has_many :damages, dependent: :destroy
  validates :name, presence: true
  before_validation -> { self.uuid = SecureRandom.uuid }, on: :create

  validates :uuid, uniqueness: true
end

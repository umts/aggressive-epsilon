class Service < ActiveRecord::Base
  has_many :permissions, dependent: :destroy

  validates :api_key, :name, :url,
            presence: true, uniqueness: true

  before_validation -> { self.api_key = SecureRandom.hex }, on: :create
end

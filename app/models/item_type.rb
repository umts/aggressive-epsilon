class ItemType < ActiveRecord::Base
  has_many :items, dependent: :destroy
  has_many :reservations, through: :items
  has_many :permissions, dependent: :destroy

  serialize :allowed_keys, Array
  before_validation -> { self.allowed_keys = allowed_keys.map(&:to_sym) }
  validate :allowed_keys_are_symbols

  validates :name, presence: true
  validates :name, uniqueness: true

  # Randomly picks an item from the available items.
  def find_available(start_datetime, end_datetime)
    items.available_between(start_datetime, end_datetime).sample
  end

  private

  def allowed_keys_are_symbols
    unless allowed_keys.map { |key| key.is_a? Symbol }.all?
      errors.add :allowed_keys, 'must be symbols'
    end
  end
end

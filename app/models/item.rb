class Item < ActiveRecord::Base
  belongs_to :item_type
  has_many :reservations

  serialize :data, Hash
  serialize :allowed_keys, Array

  validates :item_type,
            :name,
            :allowed_keys,
            presence: true

  validates :name, uniqueness: true
  validate :data_allowed

  def reserve!(start_datetime, end_datetime)
    # TODO
  end

  private

  def data_allowed
    disallowed_keys = data.keys - allowed_keys
    if disallowed_keys.present?
      errors.add :base, "Disallowed #{'key'.pluralize disallowed_keys.count}: #{disallowed_keys.join(', ')}"
    end
  end
end

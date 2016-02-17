class Permission < ActiveRecord::Base
  belongs_to :service
  belongs_to :item_type

  validates :read, :write, inclusion: { in: [true, false] }

  validates :item_type, :service,
            presence: true, uniqueness: true
end

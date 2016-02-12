class Permission < ActiveRecord::Base
  belongs_to :app
  belongs_to :item_type

  validates :read, :write, inclusion: { in: [true, false] }

  validates :item_type, :app,
            presence: true, uniqueness: true
end

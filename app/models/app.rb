class App < ActiveRecord::Base
  has_many :permissions

  validates :api_key, :name, :url,
            presence: true, uniqueness: true
end

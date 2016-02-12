class App < ActiveRecord::Base
  validates :api_key, :name, :url,
            presence: true, uniqueness: true
end

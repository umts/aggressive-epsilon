class AddReservableToItems < ActiveRecord::Migration
  def change
    add_column :items, :reservable, :boolean
  end
end

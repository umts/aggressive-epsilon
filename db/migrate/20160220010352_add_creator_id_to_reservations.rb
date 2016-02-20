class AddCreatorIdToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :creator_id, :integer
  end
end

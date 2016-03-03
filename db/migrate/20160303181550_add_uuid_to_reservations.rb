class AddUuidToReservations < ActiveRecord::Migration
  def change
    add_column :reservations, :uuid, :string
  end
end

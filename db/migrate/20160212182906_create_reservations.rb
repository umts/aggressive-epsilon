class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.datetime :start_datetime
      t.datetime :end_datetime
      t.integer :item_id

      t.timestamps null: false
    end
  end
end

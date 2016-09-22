class CreateDamages < ActiveRecord::Migration
  def change
    create_table :damages do |t|
      t.string :uuid
      t.string :damage_issued_reservation_uuid
      t.string :damage_fixed_reservation_uuid
      t.references :damage_type
      t.integer :creator_id
      t.integer :item_id

      t.timestamps null: false
    end
  end
end

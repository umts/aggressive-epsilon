class CreateDamageTypes < ActiveRecord::Migration
  def change
    create_table :damage_types do |t|
      t.string :name
      t.string :uuid
      t.integer :creator_id

      t.timestamps null: false
    end
  end
end

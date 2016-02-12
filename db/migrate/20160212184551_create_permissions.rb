class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.boolean :read, default: false
      t.boolean :write, default: false
      t.integer :item_type_id
      t.integer :app_id

      t.timestamps null: false
    end
  end
end

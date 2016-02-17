class RenameAppToService < ActiveRecord::Migration
  def up
    drop_table :apps
    create_table :services do |t|
      t.string :api_key
      t.string :name
      t.string :url

      t.timestamps null: false
    end
    remove_column :permissions, :app_id
    add_column :permissions, :service_id, :integer
  end

  def down
    drop_table :services
    create_table :apps do |t|
      t.string :api_key
      t.string :name
      t.string :url

      t.timestamps null: false
    end
    remove_column :permissions, :service_id
    add_column :permissions, :app_id, :integer
  end
end

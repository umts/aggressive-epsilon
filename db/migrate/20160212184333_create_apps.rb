class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :api_key
      t.string :name
      t.string :url

      t.timestamps null: false
    end
  end
end

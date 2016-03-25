class AddUuidToItems < ActiveRecord::Migration
  def change
    add_column :items, :uuid, :string
  end
end

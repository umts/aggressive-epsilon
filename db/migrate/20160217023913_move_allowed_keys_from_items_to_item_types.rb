class MoveAllowedKeysFromItemsToItemTypes < ActiveRecord::Migration
  def change
    remove_column :items, :allowed_keys, :string
    add_column :item_types, :allowed_keys, :string
  end
end

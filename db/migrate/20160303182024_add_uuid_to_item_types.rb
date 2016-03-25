class AddUuidToItemTypes < ActiveRecord::Migration
  def change
    add_column :item_types, :uuid, :string
  end
end

class CreatorForItemType < ActiveRecord::Migration
  def change
    add_column :item_types, :creator_id, :integer
  end
end

class AddAllowedKeysToItems < ActiveRecord::Migration
  def change
    add_column :items, :allowed_keys, :string
  end
end

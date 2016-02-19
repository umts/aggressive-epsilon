class RemoveReadFromPermissions < ActiveRecord::Migration
  def change
    remove_column :permissions, :read, :boolean
  end
end

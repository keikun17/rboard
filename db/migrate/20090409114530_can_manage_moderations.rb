class CanManageModerations < ActiveRecord::Migration
  def self.up
    add_column :permissions, :can_manage_moderations, :boolean, :default => false
  end

  def self.down
    remove_column :permissions, :can_manage_moderations
  end
end

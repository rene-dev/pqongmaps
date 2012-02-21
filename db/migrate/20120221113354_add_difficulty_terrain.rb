class AddDifficultyTerrain < ActiveRecord::Migration
  def self.up
    add_column :caches, :difficulty, :integer
    add_column :caches, :terrain   , :integer
  end

  def self.down
    remove_column :caches, :difficulty
    remove_column :caches, :terrain
  end
end

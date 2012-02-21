class CreateCaches < ActiveRecord::Migration
  def self.up
    create_table :caches do |t|
      t.string  :name
      t.string  :gccode
      t.float   :lat
      t.float   :lon
      t.integer :gc_type
    end
    add_index :caches, :gccode
  end

  def self.down
    drop_table :caches
  end
end

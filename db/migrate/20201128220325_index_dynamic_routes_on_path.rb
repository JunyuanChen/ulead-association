class IndexDynamicRoutesOnPath < ActiveRecord::Migration[6.0]
  def change
    add_index :dynamic_routes, :path
  end
end

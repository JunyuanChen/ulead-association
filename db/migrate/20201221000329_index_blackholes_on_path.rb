class IndexBlackholesOnPath < ActiveRecord::Migration[6.0]
  def change
    add_index :blackholes, :path
  end
end

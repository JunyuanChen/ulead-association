class CreateBlackholes < ActiveRecord::Migration[6.0]
  def change
    create_table :blackholes do |t|
      t.string :path, null: false

      t.timestamps
    end
  end
end

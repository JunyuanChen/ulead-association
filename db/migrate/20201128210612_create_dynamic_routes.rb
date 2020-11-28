class CreateDynamicRoutes < ActiveRecord::Migration[6.0]
  def change
    create_table :dynamic_routes do |t|
      t.string :path
      t.references :article, null: false, foreign_key: true

      t.timestamps
    end
  end
end

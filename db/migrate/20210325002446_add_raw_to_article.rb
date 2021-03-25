class AddRawToArticle < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :raw, :boolean, null: false, default: false
  end
end

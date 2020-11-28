class AddHiddenToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :hidden, :boolean, null: false, default: false
  end
end

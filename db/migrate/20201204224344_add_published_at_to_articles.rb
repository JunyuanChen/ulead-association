class AddPublishedAtToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :published_at, :datetime, precision: 6
  end
end

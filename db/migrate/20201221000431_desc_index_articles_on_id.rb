class DescIndexArticlesOnId < ActiveRecord::Migration[6.0]
  def change
    add_index :articles, :id, order: :desc
  end
end

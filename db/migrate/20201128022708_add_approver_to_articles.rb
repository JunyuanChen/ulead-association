class AddApproverToArticles < ActiveRecord::Migration[6.0]
  def change
    add_column :articles, :approver_id, :integer, default: :null
  end
end

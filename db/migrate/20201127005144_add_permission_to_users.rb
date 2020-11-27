class AddPermissionToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :permission, :integer, default: 0, null: false
  end
end

class AddNameAndRoleToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false
    add_column :users, :role, :string, null: false, default: "member"
  end
end
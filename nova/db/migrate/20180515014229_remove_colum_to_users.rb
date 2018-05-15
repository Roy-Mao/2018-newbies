class RemoveColumToUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :staff, :boolean
    remove_column :users, :remember_digest, :string
  end
end

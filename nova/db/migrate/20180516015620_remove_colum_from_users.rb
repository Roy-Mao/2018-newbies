class RemoveColumFromUsers < ActiveRecord::Migration[5.2]
  def change
    remove_column :users, :activation_digest, :string
    remove_column :users, :activated, :boolean, default: false
    remove_column :users, :activated_at, :datetime
    remove_column :users, :password_digest, :string
    remove_column :users, :reset_digest, :string
    remove_column :users, :reset_sent_at, :string
  end
end

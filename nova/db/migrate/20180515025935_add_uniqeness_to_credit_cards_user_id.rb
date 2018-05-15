class AddUniqenessToCreditCardsUserId < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :credit_cards, :users
    remove_index :credit_cards, column: :user_id
    add_index :credit_cards, :user_id, unique: true
    add_foreign_key :credit_cards, :users
  end
end

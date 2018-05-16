class AddStatusToCharges < ActiveRecord::Migration[5.2]
  def change
    add_column :charges, :status, :integer, default: 0
    add_column :charges, :stripe_id, :string
  end
end

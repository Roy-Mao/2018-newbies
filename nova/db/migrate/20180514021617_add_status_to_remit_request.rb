class AddStatusToRemitRequest < ActiveRecord::Migration[5.2]
  def change
    add_column :remit_requests, :status, :integer, default: 0
  end
end

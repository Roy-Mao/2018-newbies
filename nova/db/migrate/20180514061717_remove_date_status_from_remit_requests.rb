class RemoveDateStatusFromRemitRequests < ActiveRecord::Migration[5.2]
  def change
    remove_column :remit_requests, :accepted_at
    remove_column :remit_requests, :rejected_at
    remove_column :remit_requests, :canceled_at
  end
end

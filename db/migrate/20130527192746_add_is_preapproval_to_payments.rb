class AddIsPreapprovalToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :is_preapproval, :boolean, default: false
  end
end

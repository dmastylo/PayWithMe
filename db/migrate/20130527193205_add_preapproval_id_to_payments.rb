class AddPreapprovalIdToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :preapproval_id, :string
  end
end

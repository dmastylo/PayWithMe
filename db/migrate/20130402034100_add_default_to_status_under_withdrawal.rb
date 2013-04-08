class AddDefaultToStatusUnderWithdrawal < ActiveRecord::Migration
  def change
    change_column :withdrawals, :status, :string, default: "new"
  end
end

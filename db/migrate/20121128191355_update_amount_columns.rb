class UpdateAmountColumns < ActiveRecord::Migration
  def change
    change_column :events, :amount, :decimal, precision: 10, scale: 2, default: 0.0
    change_column :event_users, :amount, :decimal, precision: 10, scale: 2, default: 0.0
  end
end

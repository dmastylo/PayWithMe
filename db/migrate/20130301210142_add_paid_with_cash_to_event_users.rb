class AddPaidWithCashToEventUsers < ActiveRecord::Migration
  def change
    add_column :event_users, :paid_with_cash, :boolean, default: true
  end
end

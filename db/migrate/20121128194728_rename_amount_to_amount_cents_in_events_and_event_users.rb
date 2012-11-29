class RenameAmountToAmountCentsInEventsAndEventUsers < ActiveRecord::Migration
  def change
    change_column :events, :amount, :int
    rename_column :events, :amount, :amount_cents
    change_column :event_users, :amount,:int
    rename_column :event_users, :amount, :amount_cents
  end
end

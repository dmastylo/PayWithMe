class AddPaidTotalCentsToEventUsers < ActiveRecord::Migration
  def change
    add_column :event_users, :paid_total_cents, :integer, default: 0
  end
end

class RemovePaidTotalCentsCentsFromEventUsers < ActiveRecord::Migration
  def up
    remove_column :event_users, :paid_total_cents_cents
    remove_column :event_users, :paid_total_cents_currency
  end

  def down
    add_column :event_users, :paid_total_cents_currency, :string
    add_column :event_users, :paid_total_cents_cents, :integer
  end
end

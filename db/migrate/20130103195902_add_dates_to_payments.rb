class AddDatesToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :requested_at, :datetime
    add_column :payments, :paid_at, :datetime
    add_column :payments, :due_at, :datetime
    add_column :payments, :payer_id, :integer
    add_column :payments, :payee_id, :integer
    add_column :payments, :event_id, :integer
    add_column :payments, :amount_cents, :integer
  end
end

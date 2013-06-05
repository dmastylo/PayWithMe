class RemoveColumnsFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :status
    remove_column :payments, :status_type
    remove_column :payments, :transaction_id

    rename_column :payments, :processor_fee_amount_cents, :processor_fee_cents
    rename_column :payments, :our_fee_amount_cents, :our_fee_cents

    add_column :payments, :cash, :boolean
  end

  def down
  end
end

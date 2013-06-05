class DropPaymentMethodAndAssociatedTables < ActiveRecord::Migration
  def up
    drop_table :payment_methods

    remove_column :payments, :payment_method_id
    remove_column :linked_accounts, :balance_cents
    remove_column :linked_accounts, :balanced_at
  end

  def down
    raise ActiveRecord::IrreversibleMigration 
  end
end

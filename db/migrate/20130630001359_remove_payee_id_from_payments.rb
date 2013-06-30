class RemovePayeeIdFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :payee_id
  end

  def down
    add_column :payments, :payee_id, :integer
  end
end

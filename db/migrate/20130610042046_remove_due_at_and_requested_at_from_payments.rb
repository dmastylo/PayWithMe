class RemoveDueAtAndRequestedAtFromPayments < ActiveRecord::Migration
  def up
    remove_column :payments, :due_at
    remove_column :payments, :requested_at
  end

  def down
    add_column :payments, :requested_at, :datetime
    add_column :payments, :due_at, :datetime
  end
end

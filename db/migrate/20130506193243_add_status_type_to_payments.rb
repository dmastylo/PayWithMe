class AddStatusTypeToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :status_type, :integer
  end
end

class AddProcessorToPayments < ActiveRecord::Migration
  def change
    add_column :payments, :processor_id, :int
  end
end

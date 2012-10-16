class RemoveTimeFieldsFromPaymentsProcessors < ActiveRecord::Migration
  def change
    remove_column :payments_processors, :created_at
    remove_column :payments_processors, :updated_at
  end
end

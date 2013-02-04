class CreateEventPaymentMethodsTable < ActiveRecord::Migration
  def change
    create_table :event_payment_methods do |t|
      t.integer :event_id
      t.integer :payment_method_id
    end
  end
end

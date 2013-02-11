class CreateEventsPaymentMethodsTable < ActiveRecord::Migration
  def change
    create_table :events_payment_methods do |t|
      t.integer :event_id
      t.integer :payment_method_id
    end
  end
end
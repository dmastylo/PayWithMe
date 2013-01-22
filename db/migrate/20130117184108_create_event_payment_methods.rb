class CreateEventPaymentMethods < ActiveRecord::Migration
  def change
    create_table :event_payment_methods do |t|
      t.string :event_id
      t.string :payment_method

      t.timestamps
    end
  end
end

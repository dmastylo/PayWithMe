class RemovePaymentMethodFromPaymentMethods < ActiveRecord::Migration
  def up
    PaymentMethod.all.each do |payment_method|
      event = Event.find(payment_method.event_id)
      payment_method = PaymentMethod.find(payment_method.payment_method)

      if event.present? && payment_method.present?
        event.payment_methods << payment_method
      end
    end
    remove_column :payment_methods, :payment_method
  end

  def down
    add_column :payment_methods, :payment_method, :integer
  end
end
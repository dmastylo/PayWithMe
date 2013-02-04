class AddFeeInformationToPaymentMethods < ActiveRecord::Migration
  def change
    add_column :payment_methods, :static_fee_cents, :integer
    add_column :payment_methods, :percent_fee, :decimal
    add_column :payment_methods, :minimum_fee_cents, :integer
    add_column :payment_methods, :fee_threshold_cents, :integer
  end
end

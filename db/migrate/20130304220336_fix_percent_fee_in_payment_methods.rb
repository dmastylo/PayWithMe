class FixPercentFeeInPaymentMethods < ActiveRecord::Migration
  def change
    change_column :payment_methods, :percent_fee, :decimal, precision: 8, scale: 4
  end
end

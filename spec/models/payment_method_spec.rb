# == Schema Information
#
# Table name: payment_methods
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  static_fee_cents    :integer
#  percent_fee         :decimal(, )
#  minimum_fee_cents   :integer
#  fee_threshold_cents :integer
#  name                :string(255)
#

require 'spec_helper'

describe PaymentMethod do
  describe "calculating fees" do
    describe "for PayPal" do
      before { @payment_method = PaymentMethod.find_by_name("PayPal") }
      [
        [500, 46],
        [1000, 61],
        [1500, 76],
        [2500, 106],
        [10000, 330],
        [100000, 3018]
      ].each do |values|
        it "should have the right values" do
          @payment_method.processor_fee(values.first).should == values.second
          @payment_method.our_fee(values.first).should == 0
          @payment_method.processor_fee_after_our_fee(values.first).should == values.second
          @payment_method.total_fee(values.first).should == values.second
          @payment_method.total_amount(values.first).should == values.first + values.second
        end
      end
    end

    describe "for Dwolla" do
      before { @payment_method = PaymentMethod.find_by_name("Dwolla") }
        [
          [500, 0],
          [1000, 25],
          [1500, 25],
          [2500, 25],
          [10000, 25]
        ].each do |values|
          it "should have the right values" do
            @payment_method.processor_fee(values.first).should == values.second
            @payment_method.our_fee(values.first).should == 0
            @payment_method.processor_fee_after_our_fee(values.first).should == values.second
            @payment_method.total_fee(values.first).should == values.second
            @payment_method.total_amount(values.first).should == values.first + values.second
          end
        end
      end
  end

end
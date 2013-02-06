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
  before { load "#{Rails.root}/db/seeds.rb" }

  describe "calculating fees" do
    describe "for PayPal" do
      before { @payment_method = PaymentMethod.find_by_name("PayPal") }
      [
        [500, 45],
        [1000, 60],
        [1500, 75],
        [2500, 105],
        [10000, 329]
      ].each do |values|
        it { @payment_method.processor_fee(values.first).should == values.second }
      end
    end

    describe "for Dwolla" do

    end
  end

end
# == Schema Information
#
# Table name: payments
#
#  id           :integer          not null, primary key
#  payee_id     :integer
#  payer_id     :integer
#  amount       :float
#  paid_at      :datetime
#  desired_at   :datetime
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  processor_id :integer
#

require 'spec_helper'

describe Payment do
  before do
    @payer = FactoryGirl.create(:user)
    @payee = FactoryGirl.create(:user)
    @payment = Payment.new(amount: 5.95, payer: @payer, payee: @payee)
  end

  subject { @payment }
  it { should be_valid }

  describe "not valid" do
    describe "when amount is not present" do
      before { @payment.amount = "" }
      it { should_not be_valid }
    end

    describe "when amount is not a number" do
      before { @payment.amount = "cool" }
      it { should_not be_valid }
    end

    describe "when amount is negative" do
      before { @payment.amount = -5.75 }
      it { should_not be_valid }
    end

    describe "when desired at is past" do
      before { @payment.desired_at = Time.now - 86400 }
      it { should_not be_valid }
    end
  end

  describe "valid" do
    describe "when desired at is in the future" do
      before { @payment.desired_at = Time.now + 86400 }
      it { should be_valid }
    end
  end
end

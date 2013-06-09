# == Schema Information
#
# Table name: event_users
#
#  id               :integer          not null, primary key
#  event_id         :integer
#  user_id          :integer
#  amount_cents     :integer          default(0)
#  due_at           :datetime
#  paid_at          :datetime
#  invitation_sent  :boolean          default(FALSE)
#  payment_id       :integer
#  visited_event    :boolean          default(FALSE)
#  last_seen        :datetime
#  paid_with_cash   :boolean          default(TRUE)
#  paid_total_cents :integer          default(0)
#  status           :integer          default(0)
#  nudges_remaining :integer          default(0)
#  accepted_invite  :boolean          default(FALSE)
#

require 'spec_helper'

describe EventUser do
  
  before do
    @event = FactoryGirl.create(:event)
    @user = FactoryGirl.create(:user)
    @event.add_member(@user)
    @event_user = @event.event_user(@user)
  end

  subject { @event_user }
  it { should be_valid }
  it { should be_member }

  describe "attributes" do
    [:event_id,
     :user_id,
     :due_at,
     :paid_at,
     :invitation_sent,
     :visited_event].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:user_id) }
    # it { should validate_presence_of(:due_at) }
    # it { should allow_value("$1234").for(:amount) }
    # it { should_not allow_value("abcd").for(:amount) }
  end

  describe "mass assignment" do
    [:paid_at,
     :invitation_sent,
     :visited_event].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  describe "relationships" do
    it { should have_many(:payments) }
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

  describe "callbacks" do
    it "should have set due_at" do
      @event_user.due_at.should == @event.due_at
    end
    it "should have set the amount" do
      @event_user.amount_cents.should == @event.split_amount_cents
    end
  end

  describe "create_payment method" do
    it "should create a payment" do
      expect { @event_user.create_payment }.to change(@user.sent_payments, :count).by(1)
    end

    describe "amount unspecified" do
      before { @payment = @event_user.create_payment }
      it "should create a full payment" do
        @payment.amount_cents.should == @event_user.amount_cents
      end

      describe "paying the payment" do
        before { @event_user.pay!(@payment, transaction_id: "asdfghjkl") }
        it "should be able to be paid" do
          @event_user.paid?.should be_true
        end
      end 
    end

    describe "specific amount" do
      before { @payment = @event_user.create_payment(amount_cents: @event.split_amount_cents / 2) }
      it "should use that amount" do
        @payment.amount_cents.should == (@event_user.amount_cents / 2)
      end

      describe "paying the payment" do
        before { @event_user.pay!(@payment, transaction_id: "asdfghjkl") }
        it "should be able to be paid" do
          @event_user.paid_total_cents.should_not == 0
          @event_user.paid?.should_not be_true
          @event_user.paid_at.should be_nil
        end
      end
    end

    describe "paid with cash" do
      before { @payment = @event_user.create_payment(amount_cents: @event.split_amount_cents / 2) }

      it "should initially be true" do
        @event_user.paid_with_cash.should be_true
      end

      describe "when using cash" do
        before { @event_user.pay!(@payment, payment_method: PaymentMethod::MethodType::CASH) }
        it { @event_user.paid_with_cash.should be_true }
      end

      describe "when not using cash" do
        before { @event_user.pay!(@payment, payment_method: PaymentMethod::MethodType::PAYPAL) }
        it { @event_user.paid_with_cash.should_not be_true }
      end
    end
  end

end

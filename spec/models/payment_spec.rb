# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  requested_at   :datetime
#  paid_at        :datetime
#  due_at         :datetime
#  payer_id       :integer
#  payee_id       :integer
#  event_id       :integer
#  amount_cents   :integer
#  event_user_id  :integer
#  transaction_id :string(255)
#  payment_method :integer
#

require 'spec_helper'

describe Payment do
  
  before { @payment = FactoryGirl.create(:payment) }
  subject { @payment }
  it { should be_valid }

  describe "attributes" do
    [:requested_at,
     :paid_at,
     :due_at,
     :payer_id,
     :payee_id,
     :event_id,
     :amount_cents,
     :event_user_id,
     :transaction_id,
     :payment_method].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:payer_id) }
    it { should validate_presence_of(:payee_id) }
    it { should validate_presence_of(:due_at) }
    it { should validate_presence_of(:requested_at) }
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:event_user_id) }
    it { should validate_presence_of(:event_user_id) }
    it { should validate_presence_of(:payment_method) }
    it { should validate_numericality_of(:payment_method) }
    it { should validate_presence_of(:amount) }
    it { should allow_value("$1234").for(:amount) }
    it { should_not allow_value("abcd").for(:amount) }
  end

  describe "mass assignment" do
    [:requested_at,
     :paid_at,
     :payer_id,
     :payee_id,
     :event_id,
     :amount,
     :event_user_id,
     :transaction_id,
     :payment_method].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  describe "relationships" do
    it { should belong_to(:payer).class_name("Payer") }
    it { should belong_to(:payee).class_name("Payee") }
    it { should belong_to(:event) }
    it { should belong_to(:event_user) }
  end

end
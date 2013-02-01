# == Schema Information
#
# Table name: event_users
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  user_id         :integer
#  amount_cents    :integer          default(0)
#  due_at          :datetime
#  paid_at         :datetime
#  invitation_sent :boolean          default(FALSE)
#  payment_id      :integer
#  visited_event   :boolean          default(FALSE)
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
    it { should validate_presence_of(:amount_cents) }
    it { should validate_presence_of(:due_at) }
  end

  describe "mass assignment" do
    [:paid_at,
      :invitation_sent,
      :visited_event].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
  end

  describe "relationships" do
    it { should have_many(:payments) }
    it { should belong_to(:user) }
    it { should belong_to(:event) }
  end

end
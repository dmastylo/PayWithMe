# == Schema Information
#
# Table name: events
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  description            :text
#  due_at                 :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  collection_type        :integer
#  total_cents            :integer
#  per_person_cents       :integer
#  organizer_id           :integer
#  privacy_type           :integer
#  slug                   :string(255)
#  image_file_name        :string(255)
#  image_content_type     :string(255)
#  image_file_size        :integer
#  image_updated_at       :datetime
#  image_url              :string(255)
#  guest_token            :string(255)
#  send_tickets           :boolean          default(FALSE)
#  location_title         :string(255)
#  location_address       :string(255)
#  donation_goal_cents    :integer
#  minimum_donation_cents :integer
#

# Untested things that should be tested: (none)

require 'spec_helper'

describe Event do

  before { @event = FactoryGirl.create(:event) }
  subject { @event }
  it { should be_valid }

  describe "dynamic methods" do
    it { should respond_to(:collecting_by_total?) }
    it { should respond_to(:collecting_by_person?) }
    it { should respond_to(:collecting_by_donation?) }
    it { should respond_to(:collecting_by_item?) }
  end

  describe "validations" do
    it { should validate_presence_of(:organizer_id) }
    it { should validate_presence_of(:collection_type) }
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120).with_short_message(/has to be between/).with_long_message(/has to be between/) }

    describe "when collecting by total" do
      it { should allow_value("$1234").for(:total) }
      it { should_not allow_value("abcd").for(:total) }
      it { should allow_value("$1234").for(:per_person) }
      it { should allow_value("abcd").for(:per_person) }
    end

    describe "when collecting by person" do
      before { @event.collection_type = Event::Collection::PERSON }
      it { should allow_value("$1234").for(:total) }
      it { should allow_value("abcd").for(:total) }
      it { should allow_value("$1234").for(:per_person) }
      it { should_not allow_value("abcd").for(:per_person) }
    end
  end

  describe "relationships" do
    it { should belong_to(:organizer).class_name("User") }
    it { should have_many(:event_users).dependent(:destroy) }
    it { should have_many(:members).through(:event_users).class_name("User") }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:groups).through(:event_groups) }
    it { should have_many(:reminders).dependent(:destroy) }
    it { should have_many(:nudges).dependent(:destroy) }
    it { should have_many(:paying_event_users) }
    it { should have_many(:paying_members) }
    it { should have_many(:paid_event_users) }
    it { should have_many(:paid_members) }
    it { should have_many(:unpaid_event_users) }
    it { should have_many(:unpaid_members) }
  end

  describe "mass assignment" do
    [:created_at, :updated_at, :organized_id].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  describe "nudging" do
    before do
      @nudger = FactoryGirl.create(:user)
      @nudgee = FactoryGirl.create(:user)
    end

    describe "when nudger uninvited" do
      before { @event.add_member(@nudgee) }
      specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
    end

    describe "when nudgee uninvited" do
      before { @event.add_member(@nudger) }
      specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
    end

    describe "when both invited" do
      before do
        @event.add_member(@nudger)
        @event.add_member(@nudgee)
      end

      describe "and nudger is unpaid" do
        specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
      end

      describe "and both are paid" do
        before do
          [@nudgee, @nudger].each do |user|
            @event.mark_paid(user)
          end
        end

        specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
      end

      describe "and nudger is paid and nudgee is unpaid" do
        before do
          event_user = @event.event_user_of(@nudger)
          event_user.paid_at = Time.now
          event_user.save
        end

        describe "with nudges left" do
          specify { @event.can_nudge?(@nudger, @nudgee).should be_true }
        end

        describe "after already nudging the nudgee" do
          before { FactoryGirl.create(:nudge, nudgee: @nudgee, nudger: @nudger, event: @event) }
          specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
        end

        describe "without nudges left" do
          before do
            users = FactoryGirl.create_list(:user, Figaro.env.nudge_limit.to_i + 5)
            @event.add_members(users)
            users.each do |user|
              FactoryGirl.create(:nudge, nudgee: user, nudger: @nudger, event: @event)
            end
          end
          specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
        end

        describe "nudging the event organizer" do
          specify { @event.can_nudge?(@nudger, @event.organizer).should_not be_true }
        end

        describe "nudging themselves" do
          specify { @event.can_nudge?(@nudger, @nudger).should_not be_true }
        end

        describe "nudger is a stub" do
          before do
            @stub_nudger = User.create_stub("test@example.com")
            @event.add_member(@stub_nudger)
            @event.mark_paid(@stub_nudger)
          end
          specify { @event.can_nudge?(@stub_nudger, @nudgee).should_not be_true }
        end
      end
    end
  end

  describe "amounts" do
    let(:amount) { 100.00 }

    describe "when setting amount per person" do
      before do
        @event = FactoryGirl.create(:event, collection_type: Event::Collection::per_person, per_person: amount)
        @event.add_members FactoryGirl.create_list(:user, 10)
      end

      it "should have the correct per_person_cents" do
        @event.per_person.should == amount / @event.paying_members.count
      end
    end
  end
end
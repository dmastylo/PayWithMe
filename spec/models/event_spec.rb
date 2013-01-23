# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  due_at             :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  start_at           :datetime
#  division_type      :integer
#  fee_type           :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#  organizer_id       :integer
#  privacy_type       :integer
#

require 'spec_helper'

describe Event do

  before { @event = FactoryGirl.create(:event) }
  subject { @event }
  it { should be_valid }

  describe "attributes" do
    [:title,
     :description,
     :due_at,
     :created_at,
     :updated_at,
     :start_at,
     :total_amount_cents,
     :total_amount,
     :split_amount_cents,
     :split_amount,
     :organizer,
     :members,
     :fee_type,
     :division_type,
     :privacy_type].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120) }
    it { should validate_presence_of(:organizer_id) }
    it { should validate_presence_of(:division_type) }

    describe "using total division_type" do
      it { should allow_value("$1234").for(:total_amount) }
      it { should_not allow_value("abcd").for(:total_amount) }
      it { should allow_value("$1234").for(:split_amount) }
      it { should allow_value("abcd").for(:split_amount) }
    end

    describe "using split division_type" do
      before { @event.division_type = Event::DivisionType::Split }

      it { should allow_value("$1234").for(:total_amount) }
      it { should allow_value("abcd").for(:total_amount) }
      it { should allow_value("$1234").for(:split_amount) }
      it { should_not allow_value("abcd").for(:split_amount) }
    end

    [:division_type, :fee_type, :privacy_type].each do |attribute|
      it { should allow_value(Event::DivisionType::Total).for(attribute) }
      it { should_not allow_value("test").for(attribute) }
      it { should_not allow_value(123).for(attribute) }
    end
  end

  describe "associations" do
    it { should belong_to(:organizer).class_name("User") }
    it { should have_many(:event_users).dependent(:destroy) }
    it { should have_many(:members).through(:event_users).class_name("User") }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:groups).through(:event_groups) }
    it { should have_many(:reminders).dependent(:destroy) }
  end

  describe "mass assignment" do
    [:created_at,
     :updated_at,
     :organized_id].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  # describe "validations" do

  #   describe "due_at the past" do
  #     describe "on initial creation" do
  #       before { @event.due_at = Time.now - 86400 }
  #       it { should_not be_valid }
  #     end

  #     describe "on update" do
  #       before do
  #         @event.due_at = Time.now
  #         @event.save
  #         Delorean.time_travel_to "1 month from now"
  #       end
  #       after { Delorean.back_to_the_present }

  #       describe "without change" do
  #         it { should be_valid }
  #       end

  #       describe "with past change" do
  #         before { @event.due_at = Time.now + 3600 }
  #         it { should_not be_valid }
  #       end

  #       describe "with future change" do
  #         before { @event.due_at = Time.now + 86400 + 3600 }
  #         it { should be_valid }
  #       end
  #     end
  #   end
  # end

  # describe "relationships" do
  #   it { should respond_to(:organizer_id) }
  #   it { should respond_to(:organizer) }
  #   it { should respond_to(:members) }
  # end

  # describe "payment division" do
  #   it { should respond_to(:division_type) }
  #   it { should respond_to(:fee_type) }
  #   it { should respond_to(:total_amount) }
  #   it { should respond_to(:total_amount_cents) }
  #   it { should respond_to(:split_amount) }
  #   it { should respond_to(:split_amount_cents) }

  #   describe "without modifications" do
  #     before do
  #       10.times do
  #         @event.members << FactoryGirl.create(:user)
  #       end
  #     end

  #     share_examples_for "division_type calculations" do
  #       describe "with organizer paying fees" do
  #         before do
  #           @event.fee_type = Event::FeeType::OrganizerPays
  #           @event.save
  #         end

  #         it "should have nonzero entries" do
  #           @event.split_amount_cents.should_not be_nil
  #           @event.split_amount_cents.should_not == 0
  #           @event.total_amount_cents.should_not be_nil
  #           @event.total_amount_cents.should_not == 0
  #           @event.receive_amount_cents.should_not be_nil
  #           @event.receive_amount_cents.should_not == 0
  #           @event.send_amount_cents.should_not be_nil
  #           @event.send_amount_cents.should_not == 0
  #         end

  #         it "should have correct split_amount" do
  #           @event.split_amount_cents.should == @event.total_amount_cents / @event.paying_members.count
  #         end

  #         it "should have equal split_amount and send_amount" do
  #           @event.split_amount.should == @event.send_amount
  #           @event.split_amount_cents.should == @event.send_amount_cents
  #         end

  #         it "should have correct receive_amount" do
  #           total = @event.total_amount_cents * (1 - Figaro.env.fee_rate.to_f) - @event.paying_members.count * (Figaro.env.fee_static.to_f * 100.0)

  #           @event.receive_amount_cents.should == total.floor
  #         end
  #       end

  #       describe "with members paying fees" do
  #         before do
  #           @event.fee_type = Event::FeeType::MembersPay
  #           @event.save
  #         end

  #         it "should have correct split_amount" do
  #           @event.split_amount_cents.should == @event.total_amount_cents / @event.paying_members.count
  #         end

  #         it "should have correct send_amount" do
  #           send = (@event.total_amount_cents / @event.members.count + Figaro.env.fee_static.to_f * 100.0) / (1 - Figaro.env.fee_rate.to_f)

  #           @event.send_amount_cents.should == send.ceil
  #         end

  #         it "should have equal total_amount and receive_amount" do
  #           @event.total_amount.should == @event.receive_amount
  #           @event.total_amount_cents.should == @event.receive_amount_cents
  #         end

  #         # it "should have equal total calculated from send_amount and receive_amount" do
  #         #   split = @event.members.count * @event.send_amount_cents
  #         #   total = @event.receive_amount_cents
            
  #         #   split.should == total
  #         # end
  #       end
  #     end

  #     describe "with total amount set" do
  #       before do
  #         @event.total_amount = "$100.00"
  #         @event.division_type = Event::DivisionType::Total
  #       end

  #       it_behaves_like "division_type calculations"
  #     end

  #     describe "with split amount set" do
  #       before do
  #         @event.split_amount = "$10.00"
  #         @event.division_type = Event::DivisionType::Split
  #       end

  #       it_behaves_like "division_type calculations"
  #     end
  #   end
  # end
end

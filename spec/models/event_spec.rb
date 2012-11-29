# == Schema Information
#
# Table name: events
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  description        :text
#  due_on             :date
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  start_at           :datetime
#  division_type      :integer
#  fee_type           :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#

require 'spec_helper'

describe Event do
  let(:user) { FactoryGirl.create(:user) }
  before { @event = user.organized_events.build(title: "Halloween Party", description: "We need beer for our Halloween party.", due_on: Time.now + 86400, start_at: Time.now + (86400 * 7), division_type: Event::DivisionType::Fundraise) }
  it { should be_valid }

  describe "accessible attributes" do
    it "should not give access to organizer_id" do
      expect { Event.new(organizer_id: 1) }.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "validations" do
    describe "title not present" do
      before { @event.title = "" }
      it { should_not be_valid }
    end

    describe "payment_division not present" do
      before { @event.payment_division = nil }
      it { should_not be_valid }
    end

    describe "total_amount not a number" do
      before { @event.total_amount = "not.a.number" }
      describe "with payment_division total" do
        before { @event.payment_division = Event::DivisionType::Total }
        it { should_not be_valid }
      end

      describe "with payment_division other" do
        before { @event.payment_division = Event::DivisionType::Split }
        it { should be_valid }
      end
    end

    describe "split_amount not a number" do
      before { @event.split_amount = "not.a.number" }
      describe "with payment_division split" do
        before { @event.payment_division = Event::DivisionType::Split }
        it { should_not be_valid }
      end

      describe "with payment_division other" do
        before { @event.payment_division = Event::DivisionType::Total }
        it { should be_valid }
      end
    end

    share_examples_for "a date column" do |property|
      describe "#{property} in the past" do
        describe "on initial creation" do
          before { @event.send(:"#{property}=", Time.now - 86400) }
          it { should_not be_valid }
        end

        describe "on update" do
          before do
            @event.send(:"#{property}=", Time.now)
            @event.save
            Time.stub!(:now).and_return Time.now + 86400
          end

          describe "without change" do
            it { should be_valid }
          end

          describe "with past change" do
            before { @event.send(:"#{property}=", Time.now + 3600) }
            it { should_not be_valid }
          end

          describe "with future change" do
            before { @event.send(:"#{property}=", Time.now + 86400 + 3600) }
            it { should be_valid }
          end
        end
      end

    end

    it_behaves_like "a date column", :due_at
    it_behaves_like "a date column", :start_at
  end

  describe "relationships" do
    it { should respond_to(:organizer_id) }
    it { should respond_to(:organizer) }
    it { should respond_to(:members) }
  end

  describe "payment division" do
    it { should respond_to(:division_type) }
    it { should respond_to(:fee_type) }
    it { should respond_to(:total_amount) }
    it { should respond_to(:total_amount_cents) }
    it { should respond_to(:split_amount) }
    it { should respond_to(:split_amount_cents) }

    describe "without modifications" do
      before do
        10.times do
          @event.members << FactoryGirl.create(:user)
        end
      end

      share_examples_for "division_type calculations" do
        describe "with organizer paying fees" do
          before do
            @event.fee_type = Event::FeeType::OrganizerPay
            @event.save
          end

          it "should have correct split_amount" do
            @event.split_amount_cents.should == @event.total_amount_cents / @event.members.count
          end

          it "should have equal split_amount and send_amount" do
            @event.split_amount.should == @event.send_amount
            @event.split_amount_cents.should == @event.send_amount_cents
          end

          it "should have correct receive_amount" do
            before do
              let(:total, @event.total_amount_cents * (1 - Figaro.env.fee_rate) - @event.members.count * Figaro.env.fee_static)
            end

            @event.receive_amount_cents.should == total
          end

          it "should have equal total calculated from send_amount and receive_amount" do
            before do
              let(:split, @event.members.count * @event.send_amount_cents)
              let(:total, @event.receive_amount_cents)
            end
            
            split.should == total
          end
        end

        describe "with members paying fees" do
          before do
            @event.fee_type = Event::FeeType::MembersPay
            @event.save
          end

          it "should have correct split_amount" do
            @event.split_amount_cents.should == @event.total_amount_cents / @event.members.count
          end

          it "should have correct send_amount" do
            before do
              let(:send, (@event.total_amount_cents / @event.members.count + Figaro.env.fee_static) / (1 - Figaro.env.fee_rate))
            end

            @event.send_amount_cents.should == send
          end

          it "should have equal total_amount and receive_amount" do
            @event.total_amount.should == @event.receive_amount
            @event.total_amount_cents.should == @event.receive_amount_cents
          end

          it "should have equal total calculated from send_amount and receive_amount" do
            before do
              let(:split, @event.members.count * @event.send_amount_cents)
              let(:total, @event.receive_amount_cents)
            end
            
            split.should == total
          end
        end
      end

      describe "with total amount set" do
        before do
          @event.total_amount = "$100.00"
          @event.division_type = Event::DivisionType::Total
        end
      end
    end
  end
end

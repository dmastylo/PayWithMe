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
  let(:user) { FactoryGirl.create(:user) }
  before { @event = user.organized_events.build(title: "Halloween Party", description: "We need beer for our Halloween party.", due_at: Time.now + 86400, start_at: Time.now + (86400 * 7), division_type: Event::DivisionType::Fundraise, fee_type: Event::FeeType::OrganizerPays, privacy_type: Event::PrivacyType::Public) }
  subject { @event }
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

    describe "division_type not present" do
      before { @event.division_type = nil }
      it { should_not be_valid }
    end

    describe "division_type not present" do
      before { @event.fee_type = nil }
      it { should_not be_valid }
    end

    describe "total_amount not present" do
      before { @event.total_amount = nil }
      describe "with division_type total" do
        before { @event.division_type = Event::DivisionType::Total }
        it { should_not be_valid }
      end

      describe "with division_type other" do
        before do
          @event.split_amount = "$100.00"
          @event.division_type = Event::DivisionType::Split
        end
        it { should be_valid }
      end
    end

    describe "split_amount not present" do
      before { @event.split_amount = nil }
      describe "with division_type total" do
        before { @event.division_type = Event::DivisionType::Split }
        it { should_not be_valid }
      end

      describe "with division_type other" do
        before do
          @event.total_amount = "$100.00"
          @event.division_type = Event::DivisionType::Total
        end
        it { should be_valid }
      end
    end

    describe "total_amount not a number" do
      before { @event.total_amount = "not.a.number" }
      describe "with division_type total" do
        before { @event.division_type = Event::DivisionType::Total }
        it { should_not be_valid }
      end

      describe "with division_type other" do
        before do
          @event.split_amount = "$100.00"
          @event.division_type = Event::DivisionType::Split
        end
        it { should be_valid }
      end
    end

    describe "split_amount not a number" do
      before { @event.split_amount = "not.a.number" }
      describe "with division_type split" do
        before { @event.division_type = Event::DivisionType::Split }
        it { should_not be_valid }
      end

      describe "with division_type other" do
        before do
          @event.division_type = Event::DivisionType::Total
          @event.total_amount = "$100.00"
        end
        it { should be_valid }
      end
    end

    describe "due_at the past" do
      describe "on initial creation" do
        before { @event.due_at = Time.now - 86400 }
        it { should_not be_valid }
      end

      describe "on update" do
        before do
          @event.due_at = Time.now
          @event.save
          Delorean.time_travel_to "1 month from now"
        end
        after { Delorean.back_to_the_present }

        describe "without change" do
          it { should be_valid }
        end

        describe "with past change" do
          before { @event.due_at = Time.now + 3600 }
          it { should_not be_valid }
        end

        describe "with future change" do
          before { @event.due_at = Time.now + 86400 + 3600 }
          it { should be_valid }
        end
      end
    end
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
            @event.fee_type = Event::FeeType::OrganizerPays
            @event.save
          end

          it "should have nonzero entries" do
            @event.split_amount_cents.should_not be_nil
            @event.split_amount_cents.should_not == 0
            @event.total_amount_cents.should_not be_nil
            @event.total_amount_cents.should_not == 0
            @event.receive_amount_cents.should_not be_nil
            @event.receive_amount_cents.should_not == 0
            @event.send_amount_cents.should_not be_nil
            @event.send_amount_cents.should_not == 0
          end

          it "should have correct split_amount" do
            @event.split_amount_cents.should == @event.total_amount_cents / @event.paying_members.count
          end

          it "should have equal split_amount and send_amount" do
            @event.split_amount.should == @event.send_amount
            @event.split_amount_cents.should == @event.send_amount_cents
          end

          it "should have correct receive_amount" do
            total = @event.total_amount_cents * (1 - Figaro.env.fee_rate.to_f) - @event.paying_members.count * (Figaro.env.fee_static.to_f * 100.0)

            @event.receive_amount_cents.should == total.floor
          end
        end

        describe "with members paying fees" do
          before do
            @event.fee_type = Event::FeeType::MembersPay
            @event.save
          end

          it "should have correct split_amount" do
            @event.split_amount_cents.should == @event.total_amount_cents / @event.paying_members.count
          end

          it "should have correct send_amount" do
            send = (@event.total_amount_cents / @event.members.count + Figaro.env.fee_static.to_f * 100.0) / (1 - Figaro.env.fee_rate.to_f)

            @event.send_amount_cents.should == send.ceil
          end

          it "should have equal total_amount and receive_amount" do
            @event.total_amount.should == @event.receive_amount
            @event.total_amount_cents.should == @event.receive_amount_cents
          end

          # it "should have equal total calculated from send_amount and receive_amount" do
          #   split = @event.members.count * @event.send_amount_cents
          #   total = @event.receive_amount_cents
            
          #   split.should == total
          # end
        end
      end

      describe "with total amount set" do
        before do
          @event.total_amount = "$100.00"
          @event.division_type = Event::DivisionType::Total
        end

        it_behaves_like "division_type calculations"
      end

      describe "with split amount set" do
        before do
          @event.split_amount = "$10.00"
          @event.division_type = Event::DivisionType::Split
        end

        it_behaves_like "division_type calculations"
      end
    end
  end
end

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
#  division_type      :integer
#  total_amount_cents :integer
#  split_amount_cents :integer
#  organizer_id       :integer
#  privacy_type       :integer
#  slug               :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  image_url          :string(255)
#  guest_token        :string(255)
#  use_preapprovals   :boolean          default(FALSE)
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
     :total_amount_cents,
     :total_amount,
     :split_amount_cents,
     :split_amount,
     :organizer,
     :members,
     :division_type,
     :privacy_type].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:organizer_id) }
    it { should validate_presence_of(:division_type) }
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120).with_short_message(/has to be between/).with_long_message(/has to be between/) }

    describe "using total division_type" do
      it { should allow_value("$1234").for(:total_amount) }
      it { should_not allow_value("abcd").for(:total_amount) }
      it { should allow_value("$1234").for(:split_amount) }
      it { should allow_value("abcd").for(:split_amount) }
    end

    describe "using split division_type" do
      before { @event.division_type = Event::DivisionType::SPLIT }

      it { should allow_value("$1234").for(:total_amount) }
      it { should allow_value("abcd").for(:total_amount) }
      it { should allow_value("$1234").for(:split_amount) }
      it { should_not allow_value("abcd").for(:split_amount) }
    end

    [:division_type, :privacy_type].each do |attribute|
      it { should allow_value(Event::DivisionType::TOTAL).for(attribute) }
      it { should_not allow_value("test").for(attribute) }
      it { should_not allow_value(123).for(attribute) }
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
    it { should have_and_belong_to_many(:payment_methods) }
    it { should have_many(:nudges).dependent(:destroy) }
  end

  describe "mass assignment" do
    [:created_at,
     :updated_at,
     :organized_id].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  describe "members" do
    it { @event.members.should include(@event.organizer) }

    describe "adding" do
      describe "multiple" do
        before do
          @members = FactoryGirl.create_list(:user, 10)
          @event.add_members(@members)
        end
        it "should include all members" do
          @members.each do |member|
            @event.members.should include(member)
          end
        end
      end

      describe "single" do
        before do
          @member = FactoryGirl.create(:user)
          @event.add_member(@member)
        end
        it { @event.members.should include(@member) }
      end
    end

    describe "setting" do
      before do
        @original_members = FactoryGirl.create_list(:user, 10)
        @event.add_members(@original_members)
        @new_members = FactoryGirl.create_list(:user, 10)
        @event.set_members(@new_members)
      end

      it { @event.members.should eq @new_members }
      it "should not include uninvited members" do
        @original_members.each do |member|
          @event.members.should_not include(member)
        end
      end
    end

    describe "removing" do
      describe "multiple" do
        before do
          @uninvited_members = FactoryGirl.create_list(:user, 3)
          @new_members = FactoryGirl.create_list(:user, 3)
          @event.add_members(@uninvited_members + @new_members)
          @event.remove_members(@uninvited_members)
        end

        it "should not include uninvited members" do
          @uninvited_members.each do |member|
            @event.members.should_not include(member)
          end
        end

        it "should include other members" do
          @new_members.each do |member|
            @event.members.should include(member)
          end
        end
      end

      describe "single" do
        before do
          @uninvited_member = FactoryGirl.create(:user)
          @new_members = FactoryGirl.create_list(:user, 3)
          @event.add_members([@uninvited_member] + @new_members)
          @event.remove_member(@uninvited_member)
        end

        it "should not include uninvited member" do
          @event.members.should_not include(@uninvited_member)
        end

        it "should include other members" do
          @new_members.each do |member|
            @event.members.should include(member)
          end
        end
      end
    end
  end

  describe "locking" do
    describe "unlocked" do
      before do
        @user = FactoryGirl.create(:user)
        @event.add_member(@user)
      end

      it "should allow changing total_amount" do
        expect do
          @event.total_amount = 123
          @event.save
        end.to change { Event.find_by_id(@event.id).total_amount_cents }.to(12300)
      end
    end

    describe "locked" do
      before do
        @user = FactoryGirl.create(:user)
        @event.add_member(@user)
        event_user = @event.event_user(@user)
        event_user.paid_at = true
        event_user.save
      end

      it "should allow changing total_amount" do
        expect do
          @event.total_amount = 123
          @event.save
        end.to_not change { Event.find_by_id(@event.id).total_amount_cents }.to(12300)
      end
    end
  end

  describe "nudging" do
    before do
      @nudger = FactoryGirl.create(:user)
      @nudgee = FactoryGirl.create(:user)
    end

    describe "nudger uninvited" do
      before do
        @event.add_member(@nudgee)
      end
      specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
    end

    describe "nudgee uninvited" do
      before do
        @event.add_member(@nudger)
      end
      specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
    end

    describe "both invited" do
      before do
        @event.add_member(@nudger)
        @event.add_member(@nudgee)
      end

      describe "unpaid" do
        specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
      end

      describe "both paid" do
        before do
          [@nudgee, @nudger].each do |user|
            @event.mark_paid(user)
          end
        end

        specify { @event.can_nudge?(@nudger, @nudgee).should_not be_true }
      end

      describe "nudger paid and nudgee unpaid" do
        before do
          event_user = @event.event_user(@nudger)
          event_user.paid_at = Time.now
          event_user.save
        end

        describe "with nudges left" do
          specify { @event.can_nudge?(@nudger, @nudgee).should be_true }
        end

        describe "already nudged" do
          before do
            FactoryGirl.create(:nudge, nudgee: @nudgee, nudger: @nudger, event: @event)
          end

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
        @event = FactoryGirl.create(:event, division_type: Event::DivisionType::SPLIT, split_amount: amount)
        @event.add_members FactoryGirl.create_list(:user, 10)
      end

      # @Austin Gulati could you look at this?
      # Off by like 6 bucks
      it "should have the correct split_amount_cents" do
        receive_amount = ((@event.split_amount_cents - Figaro.env.fee_static.to_f * 100.0) * (1.0 - Figaro.env.fee_rate.to_f)).round / 100.0
        receive_amount.should == amount
      end
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

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
    it { should ensure_length_of(:title).is_at_least(2).is_at_most(120).with_short_message(/has to be between/).with_long_message(/has to be between/) }
    it { should validate_presence_of(:organizer_id) }
    it { should validate_presence_of(:division_type) }

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

  describe "associations" do
    it { should belong_to(:organizer).class_name("User") }
    it { should have_many(:event_users).dependent(:destroy) }
    it { should have_many(:members).through(:event_users).class_name("User") }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:event_groups).dependent(:destroy) }
    it { should have_many(:groups).through(:event_groups) }
    it { should have_many(:reminders).dependent(:destroy) }
    it { should have_and_belong_to_many(:payment_methods) }
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
end

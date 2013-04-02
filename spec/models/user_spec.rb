# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0)
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :string(255)
#  last_sign_in_ip            :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  name                       :string(255)
#  profile_image_file_name    :string(255)
#  profile_image_content_type :string(255)
#  profile_image_file_size    :integer
#  profile_image_updated_at   :datetime
#  profile_image_url          :string(255)
#  stub                       :boolean          default(FALSE)
#  guest_token                :string(255)
#  using_oauth                :boolean
#  last_seen                  :datetime
#  time_zone                  :string(255)      default("Eastern Time (US & Canada)")
#  slug                       :string(255)
#  creator_id                 :integer
#  completed_at               :datetime
#  admin                      :boolean
#  send_emails                :boolean          default(TRUE)
#  using_cash                 :boolean          default(FALSE)
#

require 'spec_helper'

describe User do
  
  before { @user = FactoryGirl.create(:user) }
  subject { @user }
  it { should be_valid }
  it { should_not be_stub }

  describe "attributes" do
    [:name,
     :email,
     :password,
     :password_confirmation,
     :encrypted_password,
     :stub,
     :profile_image_type,
     :profile_image_url,
     :time_zone,
     :last_seen,
     :using_oauth,
     :guest_token,
     :slug,
     :admin].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should ensure_length_of(:name).is_at_least(2).is_at_most(50).with_short_message(/has to be between/).with_long_message(/has to be between/) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value("test@test.com").for(:email) }
    it { should allow_value("test+testing@test.com").for(:email) }
    it { should_not allow_value("test.com").for(:email) }
    it { should_not allow_value("test@test").for(:email) }
    it { should_not allow_value("test@.com").for(:email) }
    it { should_not allow_value("@test.com").for(:email) }
    it { should ensure_length_of(:password).is_at_least(6) }
    it { should_not allow_value("Not A Time Zone").for(:time_zone) }
    it { should allow_value("Eastern Time (US & Canada)").for(:time_zone) }
  end

  describe "associations" do
    it { should have_many(:organized_events).class_name("Event") }
    it { should have_many(:event_users).dependent(:destroy) }
    it { should have_many(:member_events).class_name("Event").through(:event_users).dependent(:destroy) }
    it { should have_many(:organized_groups).class_name("Group") }
    it { should have_many(:group_users).dependent(:destroy) }
    it { should have_many(:member_groups).class_name("Group").through(:group_users) }
    it { should have_many(:messages).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:linked_accounts).dependent(:destroy) }
    it { should have_many(:news_items).dependent(:destroy) }
    it { should have_many(:received_payments).class_name("Payment") }
    it { should have_many(:sent_payments).class_name("Payment") }
    it { should have_many(:received_nudges).class_name("Nudge") }
    it { should have_many(:sent_nudges).class_name("Nudge") }
    it { should belong_to(:creator).class_name("User") }
  end

  describe "mass assignment" do
    [:encrypted_password,
     :reset_password_token,
     :reset_password_sent_at,
     :remember_created_at,
     :sign_in_count,
     :current_sign_in_ip,
     :current_sign_in_at,
     :last_sign_in_at,
     :last_sign_in_ip,
     :created_at,
     :updated_at,
     :profile_image_file_name,
     :profile_image_file_size,
     :profile_image_content_type,
     :profile_image_updated_at,
     :stub,
     :guest_token,
     :last_seen,
     :admin].each do |attribute|
      it { should_not allow_mass_assignment_of(attribute) }
    end
  end

  describe "when stub" do
    before { @user = User.create_stub("test@test.com") }

    describe "validations" do
      it { should_not validate_presence_of(:password) }
      it { should_not validate_presence_of(:name) }
      it { should validate_presence_of(:guest_token) }
      it { should_not allow_value("@test.com").for(:email) }
    end

    it { @user.password_required?.should == false }
  end

  describe "when using oauth" do
    before { @user = FactoryGirl.create(:oauth_user) }

    describe "validations" do
      it { should_not validate_presence_of(:password) }
    end

    it { @user.password_required?.should == false }
  end

  describe "events" do
    before do
      @event = FactoryGirl.create(:event)
      @user = @event.organizer
    end

    it { @user.organized_events.should include(@event) }
    it { @user.member_events.should include(@event) }
  end

  describe "search" do
    before do
      @base_user = FactoryGirl.create(:user)
      @enemy_users = FactoryGirl.create_list(:user, 10)
    end

    describe "without events" do
      before do
        @results = User.search_by_name_and_email("person", @base_user)
      end

      it "should be empty" do
        @results.should be_empty
      end
    end

    describe "with events" do
      before do
        @friend_users = FactoryGirl.create_list(:user, 10)
        @event = FactoryGirl.create(:event)
        @event.add_members(@friend_users + [ @base_user ])
        @results = User.search_by_name_and_email("person", @base_user)
      end
      
      it "should not contain enemy users" do
        @enemy_users.each do |user|
          @results.should_not include(user)
        end
      end

      it "should contain friend users" do
        @friend_users.each do |user|
          @results.should include(user)
        end
      end

      it "should not contain the context user" do
        @results.should_not include(@base_user)
      end
    end

    describe "with groups" do
      before do
        @friend_users = FactoryGirl.create_list(:user, 10)
        @group = FactoryGirl.create(:group)
        @group.add_members(@friend_users + [ @base_user ])
        @results = User.search_by_name_and_email("person", @base_user)
      end
      
      it "should not contain enemy users" do
        @enemy_users.each do |user|
          @results.should_not include(user)
        end
      end

      it "should contain friend users" do
        @friend_users.each do |user|
          @results.should include(user)
        end
      end

      it "should not contain the context user" do
        @results.should_not include(@base_user)
      end
    end

  end
end

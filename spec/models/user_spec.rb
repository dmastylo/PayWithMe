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
#

require 'spec_helper'

describe User do
  
  before do
    @user = FactoryGirl.create(:user)
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:encrypted_password) }
  it { should respond_to(:organized_events) }
  it { should respond_to(:member_events) }
  it { should respond_to(:profile_image_url) }
  it { should respond_to(:stub) }

  it { should be_valid }
  it { should_not be_stub }

  describe "accessible attributes" do
    it "should not allow access to stub" do
      expect do
        User.new(stub: true)
      end.to raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
  end

  describe "validation" do
    describe "when a password is too short" do
      before { @user.password = @user.password_confirmation = "x" * 5 }
      it { should_not be_valid }
    end

    describe "when a password doesn't match confirmation" do
      before { @user.password_confirmation = "mismatch" }
      it { should_not be_valid }
    end

    describe "when name is not present" do
      before { @user.name = nil }
      it { should_not be_valid }
    end
    
    describe "when email is not present" do
      before { @user.email = nil }
      it { should_not be_valid }
    end

    describe "when email is invalid" do
      before { @user.email = "not.an.email" }
      it { should_not be_valid }
    end

    after do
      @user.destroy
    end

  end

  describe "when stub" do
    before do
      @user = FactoryGirl.create(:user)
      @user.stub = true
    end

    describe "validation" do
      describe "when password is not present" do
        before { @user.password = @user.password_confirmation = nil }
        it { should be_valid }
      end

      describe "when name is not present" do
        before { @user.name = "" }
        it { should be_valid }
      end

      describe "when email is not present" do
        before { @user.email = "" }
        it { should_not be_valid }
      end

      describe "when email is invalid" do
        before { @user.email = "not.an.email" }
        it{ should_not be_valid }
      end
    end
  end
end

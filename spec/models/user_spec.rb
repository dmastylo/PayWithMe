# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string(255)
#  username               :string(255)
#  image                  :string(255)
#

require 'spec_helper'

describe User do

  before do
    @user = User.new(name: "Example User", username: "exampleuser", email: "user@example.com", password: "foobar", password_confirmation: "foobar")
  end

  subject { @user }
  it { should be_valid }

  describe "not valid" do
    describe "when name is not present" do
      before { @user.name = " " }
      it { should_not be_valid }
    end

    describe "when email is not present" do
      before { @user.email = "" }
      it { should_not be_valid }
    end

    describe "when email is taken" do
      before { FactoryGirl.create(:user, email: @user.email) }
      it { should_not be_valid }
    end

    describe "when username is not present" do
      before { @user.username = "" }
      it { should_not be_valid }
    end

    describe "when username is taken" do
      before { FactoryGirl.create(:user, username: @user.username) }
      it { should_not be_valid }
    end
  end

  describe "friendship" do
    before do
      @user.save
      @other_user = FactoryGirl.create(:user)
    end
    
    describe "valid creation" do
      it "should create a friend request" do
        expect do
          @user.send_friend_request!(@other_user)
        end.to change(Friendship, :count).by(1)
      end

      it "should not be accepted" do
        @user.send_friend_request!(@other_user)
        Friendship.where(user_id: @user.id, friend_id: @other_user.id).first.accepted.should == 0
      end

      # it "should create a notification" do
      #   expect do
      #     @user.send_friend_request!(@other_user)
      #   end.to change(Notification, :count).by(1)
      # end

      # it "should create a notification owned by the right user" do
      #   expect do
      #     @user.send_friend_request!(@other_user)
      #   end.to change(@other_user.notifications, :count).by(1)
      # end
    end

    describe "invalid creation" do
      before do
        @user.send_friend_request!(@other_user)
        @other_user.accept_friend!(@user)
      end

      it "should not create a friend request" do
        expect do
          @user.send_friend_request!(@other_user)
        end.to change(Friendship, :count).by(0)
      end

      it "should still be accepted" do
        @user.send_friend_request!(@other_user)
        Friendship.where(user_id: @user.id, friend_id: @other_user.id).first.accepted.should == 1
        @user.friends_with?(@other_user).should be_true
      end

      # it "should not create a notification" do
      #   expect do
      #     @user.send_friend_request!(@other_user)
      #   end.to change(Notification, :count).by(0)
      # end
    end

    describe "friends method" do
      before do
        @user.send_friend_request!(@other_user)
        @other_user.accept_friend!(@user)
      end

      it "should include initiator" do
        @user.friends.should include(@other_user)
      end

      it "should include initiated" do
        @other_user.friends.should include(@user)
      end
    end
  end

  describe "finding friends" do
    before do
      @user.save

      # First user
      @other_user = FactoryGirl.create(:user, name: "FoO")
      @user.send_friend_request!(@other_user)
      @other_user.accept_friend!(@user)

      # Second user
      @another_user = FactoryGirl.create(:user, name: "BaR")
      @another_user.send_friend_request!(@user)
      @user.accept_friend!(@another_user)

      # Third user
      @more_user = FactoryGirl.create(:user, name: "FoobaR")
      @user.send_friend_request!(@more_user)
      @more_user.accept_friend!(@user)

      # Make searches
      @results_one = @user.find_friends_by_name("foo")
      @results_two = @user.find_friends_by_name("bar")
      @results_three = @user.find_friends_by_name("foobar")
      @results_four = @user.find_friends_by_name("baz")
    end

    it "should include correct users" do
      @results_one.should include(@other_user, @more_user)
      @results_two.should include(@another_user, @more_user)
      @results_three.should include(@more_user)
      @results_four.should be_empty
    end
  end

  describe "request methods" do
    before do
      @user.save
      @other_user = FactoryGirl.create(:user)
      @user.send_friend_request!(@other_user)
    end

    describe "unaccepted request" do
      describe "friends_with?" do 
        it "should not be true" do
          @user.friends_with?(@other_user).should_not be_true
        end
      end

      describe "friends_sent?" do
        it "should be true for user" do
          @user.friends_sent?(@other_user).should be_true
        end

        it "should not be true for other user" do
          @other_user.friends_sent?(@user).should_not be_true
        end
      end

      describe "friends_received?" do
        it "should not be true for user" do
          @user.friends_received?(@other_user).should_not be_true
        end

        it "should be true for other user" do
          @other_user.friends_received?(@user).should be_true
        end
      end
    end
  end

end
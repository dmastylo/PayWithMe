require 'spec_helper'

describe "Admin" do

  subject { page }
  let(:pages) { [:index, :events, :users, :groups, :statistics] }

  describe "not signed in" do
    pages.each do |page|
      before { visit send("admin_#{page}_path") }
      it "should redirect to login page" do
        it { should have_selector("h2", text: "Sign in") }
        it { should have_selector("title", text: "Sign in") }
      end
    end
  end

  describe "not admin user" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    pages.each do |page|
      before { visit send("admin_#{page}_path") }
      it "should redirect to index page" do
        it { should have_selector("h2", text: "News Feed") }
        it { should have_selector("title", text: "PayWithMe") }
      end
    end
  end

  describe "as admin user" do
    before do
      @user = FactoryGirl.create(:admin_user)
      sign_in @user
    end

    pages.each do |page|
      before { visit send("admin_#{page}_path") }
      it "should render page" do
        it { should have_selector("title", text: "Administrator Panel") }
      end
    end
  end

end
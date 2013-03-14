require 'spec_helper'

describe "Event pages" do
  
  subject { page }

  describe "creation" do
    before do
      sign_in FactoryGirl.create(:user)
      visit new_group_path
    end

    it { should have_selector("h2", text: "New Group") }
    it { should have_selector("title", text: full_title("New Group")) }

    describe "with invalid information" do
      before { click_button "Create group" }

      it { should have_selector("title", text: full_title("New Group")) }
      it { should have_selector("div.alert.alert-error", text: "can't be blank") }
    end

    describe "with valid information" do
      before do
        fill_in "Title", with: "Test Group"
        fill_in "Description", with: "This is a test group"
        find(:xpath, "//input[@id='event_members']").set FactoryGirl.create_list(:user, 2).collect { |user| user.email }.to_json
        click_button "Create group"
      end

      it { should have_selector("title", text: full_title("Test Group")) }
    end
  end

end
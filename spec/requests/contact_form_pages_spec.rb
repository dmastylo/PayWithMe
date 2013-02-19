require 'spec_helper'

describe "Contact Form pages" do
  subject { page }

  before { visit new_contact_form_path }
  it { should have_selector("h2", text: "Contact Us") }
  it { should have_selector("title", text: full_title("Contact Us")) }

  describe "submission" do
    describe "with invalid information" do
      before { click_button "Send message" }

      it { should have_selector("title", text: full_title("Contact Us")) }
      it { should have_selector("div.alert.alert-error", text: "can't be blank") }
    end

    describe "with valid information" do
      before do
        fill_in "Name", with: "Test User"
        fill_in "Email", with: "test@test.com"
        fill_in "Message", with: "Hey, I just had a quick comment about your service. I forgot it, though."
        click_button "Send message"
      end

      it { current_path.should == root_path }
      it { should have_selector("title", text: full_title("")) }
    end
  end
end
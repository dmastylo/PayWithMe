require 'spec_helper'

describe "Event pages" do
  
  subject { page }

  describe "submission" do
    before do
      sign_in FactoryGirl.create(:user)
      visit new_event_path
    end

    it { should have_selector("h2", text: "New Event") }
    it { should have_selector("title", text: full_title("New Event")) }

    describe "with invalid information" do
      before { click_button "Create event and send invitations" }

      it { should have_selector("title", text: full_title("New Event")) }
      it { should have_selector("div.alert.alert-error", text: "can't be blank") }
    end

    describe "with valid information" do
      before do
        fill_in "Title", with: "Test Event"
        fill_in "Description", with: "This is a test event"
        fill_in "event_due_at_date", with: 7.days.from_now.strftime("%m/%d/%Y")
        fill_in "event_due_at_time", with: "06:00 PM"
        fill_in "Total Amount", with: 100
        find(:xpath, "//input[@id='event_division_type']").set 1
        find(:xpath, "//input[@id='event_privacy_type']").set 1
        find(:xpath, "//input[@id='event_payment_methods_raw']").set [1, 2].to_json
        find(:xpath, "//input[@id='event_members']").set FactoryGirl.create_list(:user, 2).collect { |user| user.email }.to_json
        click_button "Create event and send invitations"
      end

      it { should have_selector("title", text: full_title("Test Event")) }
    end
  end

  describe "show page" do
    before do
      @public_event = FactoryGirl.create(:event)
      @private_event = FactoryGirl.create(:event, privacy_type: Event::PrivacyType::PRIVATE)
    end
    
    describe "not signed in" do
      describe "public event" do
        before { visit event_path(@public_event) }

        it { should have_selector("h2", text: @public_event.title) }
        it { should have_selector("title", text: @public_event.title) }
      end

      describe "private event" do
        before { visit event_path(@private_event) }

        it { should have_selector("h2", text: "Sign in") }
        it { should have_selector("title", text: "Sign In") }
      end
    end

    describe "signed in" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "public event" do
        before { visit event_path(@public_event) }

        it { should have_selector("h2", text: @public_event.title) }
        it { should have_selector("title", text: @public_event.title) }
      end

      describe "private event" do
        describe "when invited" do
          before do
            @private_event.add_member(@user)
            visit event_path(@private_event)
          end

          it { should have_selector("h2", text: @private_event.title) }
          it { should have_selector("title", text: @private_event.title) }
        end

        describe "when not invited" do
          before { visit event_path(@private_event) }

          it { should have_selector("title", text: full_title("")) } # Redirects to root_path
        end
      end
    end
  end

end
require 'spec_helper'

describe "Event" do
  
  subject { page }

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

          it { should have_selector("title", text: "PayWithMe") } # Redirects to root_path
        end

      end
    end

  end

end
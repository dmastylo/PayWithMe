require 'spec_helper'

describe "Event pages" do
  
  subject { page }

  describe "creation" do
    before do
      @event = FactoryGirl.create(:event)
      @user = FactoryGirl.create(:user)
      sign_in @user
    end

    describe "with non-invited user" do
      before { visit event_path(@event) }

      it { should have_selector("title", text: full_title("")) } # Redirects to root_path
    end

    describe "with invited user" do
      describe "single message" do
        before do
          @event.add_member(@user)
          visit event_path(@event)
          find(:xpath, "//textarea[@id='message_message']").set "test message"
        end

        it { should have_selector("h2", text: @event.title) }
        it { should have_selector("title", text: full_title(@event.title)) }

        it "should create the message" do
          expect { click_button "Post Message" }.to change(Message, :count).by(1)
          should have_selector("li", class: "message")
        end
      end

      describe "quick messages in succession" do
        before do
          @event.add_member(@user)
          visit event_path(@event)
          find(:xpath, "//textarea[@id='message_message']").set "test message"
        end

        it { should have_selector("h2", text: @event.title) }
        it { should have_selector("title", text: full_title(@event.title)) }

        it "should create the message" do
          expect { click_button "Post Message" }.to change(Message, :count).by(1)
          should have_selector("li", class: "message")
        end

        it "should not allow messages in succession" do
          old_count = @event.messages.count

          2.times do
            find(:xpath, "//textarea[@id='message_message']").set "test message2"
            click_button "Post Message"
          end

          @event.messages.count.should == old_count + 1
        end
      end
    end
  end

end
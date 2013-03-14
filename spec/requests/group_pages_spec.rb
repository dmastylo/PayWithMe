require 'spec_helper'

describe "Group pages" do
  
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
        find(:xpath, "//input[@id='group_members']").set FactoryGirl.create_list(:user, 2).collect { |user| user.email }.to_json
      end

      it "should create the group and group_users" do
        expect { click_button "Create group" }.to change(GroupUser, :count).by(3)
        should have_selector("title", text: full_title("Test Group"))
      end
    end
  end

  describe "editing/updating" do
    before do
      @group = FactoryGirl.create(:group)
      @user = @group.organizer
      sign_in @user
      visit edit_group_path(@group)
    end

    describe "with invalid information" do
      before do
        fill_in "Title", with: ""
        click_button "Update group"
      end

      it { should have_selector("title", text: full_title("Edit Group")) }
      it { should have_selector("div.alert.alert-error", text: "can't be blank") }
    end

    describe "with valid information" do
      before { click_button "Update group" }

      it { should have_selector("title", text: full_title("#{@group.title} Dashboard")) }
    end
  end

  describe "show page" do
    before do
      @group = FactoryGirl.create(:group)
    end
    
    describe "not signed in" do
      describe "group" do
        before { visit group_path(@group) }

        it { should have_selector("h2", text: "Sign In") }
        it { should have_selector("title", text: "Sign In") }
        it { should have_selector("div.alert.alert-info", text: "You need to sign in or sign up before continuing.") }
      end
    end

    describe "signed in" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "group" do
        describe "when invited" do
          before do
            @group.add_member(@user)
            visit group_path(@group)
          end

          it { should have_selector("h2", text: @group.title) }
          it { should have_selector("title", text: @group.title) }
        end

        describe "when not invited" do
          before { visit group_path(@group) }

          it { should have_selector("title", text: full_title("")) } # Redirects to root_path
        end
      end
    end
  end

  describe "index page" do
    before do
      @group = FactoryGirl.create(:group)
    end

    describe "not signed in" do
      describe "group index" do
        before { visit groups_path }

        it { should have_selector("h2", text: "Sign In") }
        it { should have_selector("title", text: "Sign In") }
        it { should have_selector("div.alert.alert-info", text: "You need to sign in or sign up before continuing.") }
      end
    end

    describe "signed in" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
      end

      describe "group" do
        describe "when invited" do
          before do
            @group.add_member(@user)
            visit groups_path
          end

          it { should have_selector("h2", text: "My Groups") }
          it { should have_selector("h4", text: @group.title) }
          it { should have_selector("title", text: "My Groups") }
        end

        describe "when not invited" do
          before { visit groups_path }

          it { should have_selector("a", text: "create a group?") } # Redirects to root_path
        end
      end
    end
  end

end
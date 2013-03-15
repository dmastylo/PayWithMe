require 'spec_helper'

describe "User pages" do

  subject { page }

  describe "show page" do
    before do
      @user = FactoryGirl.create(:user)
      sign_in @user
      visit user_path(@user)
    end

    it { should have_selector("title", text: full_title(@user.name)) }
    it { should have_selector("h2", text: @user.name) }
  end

end
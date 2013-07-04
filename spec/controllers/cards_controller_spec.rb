require 'spec_helper'

describe CardsControler do
  include Devise::TestHelpers
  let(:current_user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event, members: [current_user]) }
  before { sign_in current_user }

  describe "GET #index" do
    let(:card) { FactoryGirl.create(:card, user: current_user) }
    it "finds cards" do
      card = FactoryGirl.create(:card, user: current_user)
      get :index
      assigns(:cards).should eq([card])
    end

    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    # This action doesn't exist yet
    it "throws a 404 error" do
      card = FactoryGirl.create(:card, user: current_user)
      get :show, id: card
      response.response_code.should eq(404)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new card" do
        expect {
          post :create, card: FactoryGirl.attributes_for(:card)
        }.to change(current_user.cards, :count).by(1)
      end

      it "creates an account" do
        # Assumes that this is the users first card
        expect {
          post :create, card: FactoryGirl.attributes_for(:card)
        }.to change(Account, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "does not save the card" do
        expect {
          post :create, event: FactoryGirl.attributes_for(:invalid_card)
        }.to_not change(Card, :count)
      end

      # It is not important what view is rendered
    end
  end
end
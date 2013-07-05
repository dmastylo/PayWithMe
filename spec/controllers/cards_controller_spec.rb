require 'spec_helper'

describe CardsController do
  include Devise::TestHelpers
  let(:current_user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event, members: [current_user]) }
  before { sign_in current_user }

  describe "GET #index" do
    # Disabled temporarily, do not delete
    # it "finds cards" do
    #   card = FactoryGirl.create(:card, account: FactoryGirl.create(:account, user: current_user))
    #   get :index
    #   assigns(:cards).should eq([card])
    # end

    # it "renders the :index view" do
    #   get :index
    #   response.should render_template :index
    # end
  end

  describe "GET #show" do
    # This action should not be available
    it "throws a 404 error" do
      card = FactoryGirl.create(:card, account: FactoryGirl.create(:account, user: current_user))
      expect {
        get :show, id: card
      }.to raise_error(ActionController::RoutingError)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new card" do
        expect {
          post :create, card: FactoryGirl.attributes_for(:card, uri: test_card_uri)
        }.to change(Card, :count).by(1)
      end

      it "creates an account" do
        # Assumes that this is the users first card
        expect {
          post :create, card: FactoryGirl.attributes_for(:card, uri: test_card_uri)
        }.to change(Account, :count).by(1)
      end
    end

    context "with invalid attributes" do
      it "does not save the card" do
        expect {
          post :create, card: FactoryGirl.attributes_for(:invalid_card)
        }.to_not change(Card, :count)
      end

      # It is not important what view is rendered
    end
  end
end
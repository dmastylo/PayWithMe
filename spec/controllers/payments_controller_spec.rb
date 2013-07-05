require 'spec_helper'

describe PaymentsController do
  include Devise::TestHelpers
  let(:current_user) { FactoryGirl.create(:user) }
  let(:payment) { FactoryGirl.create(:payment, payer: current_user) }

  describe "GET #index" do
    it "has not been implemented"
  end

  describe "GET #pay" do
    it "finds the requested payment" do
      get :pay, id: payment
      assigns(:payment).should eq(payment)
    end

    it "renders the :pay view" do
      get :pay, id: payment
      response.should render_template :play
    end
  end

  describe "POST #paid" do
    context "with amount set" do
      it "should mark the payment paid" do
        
      end
    end

    context "without amount set" do

    end
  end
end
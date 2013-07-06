require 'spec_helper'

describe EventsController do
  include Devise::TestHelpers
  let(:current_user) { FactoryGirl.create(:user) }
  before { sign_in current_user }

  describe "GET #index" do
    it "find events" do
      event = FactoryGirl.create(:event, organizer: current_user)
      get :index
      assigns(:upcoming_events).should eq([event])
    end

    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #show" do
    it "finds the requested event" do
      event = FactoryGirl.create(:event)
      get :show, id: event
      assigns(:event).should eq(event)
    end

    it "renders the :show view" do
      get :show, id: FactoryGirl.create(:event)
      response.should render_template :show
    end
  end

  describe "GET #new" do
    it "renders the #new view" do
      get :new
      response.should render_template :new
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new event" do
        expect {
          post :create, event: FactoryGirl.attributes_for(:event)
        }.to change(current_user.organized_events, :count).by(1)
      end

      it "adds members" do
        # Tracks creation of record in join table
        # Expect Payment to be created for event organizer
        expect {
          post :create, event: FactoryGirl.attributes_for(:event).merge(members: "[\"foo@bar.com\",\"baz@foo.com\"]")
        }.to change(Payment, :count).by(3)
      end
    end

    context "with invalid attributes" do
      it "does not save the event" do
        expect {
          post :create, event: FactoryGirl.attributes_for(:invalid_event)
        }.to_not change(Event, :count)
      end

      it "re-renders the #new view" do
        post :create, event: FactoryGirl.attributes_for(:invalid_event)
        response.should render_template :new
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @event = FactoryGirl.create(:event, organizer: current_user)
    end
    context "with valid attributes" do
      it "finds the requested event" do
        put :update, id: @event, event: FactoryGirl.attributes_for(:event)
        assigns(:event).should eq(@event)
      end

      it "updates the event" do
        put :update, id: @event, event: FactoryGirl.attributes_for(:event, title: "New Event Title")
        @event.reload
        @event.title.should eq("New Event Title")
      end
    end

    context "with invalid attributes" do
      it "doesn't update the event" do
        put :update, id: @event, event: FactoryGirl.attributes_for(:invalid_event, title: "")
        @event.reload
        @event.title.should_not eq("")
      end

      it "re-renders the #edit view" do
        put :update, id: @event, event: FactoryGirl.attributes_for(:invalid_event)
        response.should render_template :edit
      end
    end
  end

  describe "DELETE #destroy" do
  end
end
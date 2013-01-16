class RemindersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_organizes_event

  def new
    @reminder = @event.reminders.new
  end

  def create
    @reminder = @event.reminders.new(params[:reminder])

    if @reminder.save
      flash[:success] = "Reminder created!"

      if @reminder.all?
        @reminder.add_users(@event.members, @event.organizer)
      elsif @reminder.paid?
        @reminder.add_users(@event.paid_members, @event.organizer)
      elsif @reminder.unpaid?
        @reminder.add_users(@event.unpaid_members, @event.organizer)
      end

      Reminder.delay.send_emails(@reminder.id)
      redirect_to admin_event_path(@event)
    else
      render "new"
    end
  end

end
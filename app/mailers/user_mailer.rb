class UserMailer < ActionMailer::Base
  default from: "PayWithMe <#{Figaro.env.gmail_username}>"
  helper :application
  layout 'mail'

  def signup_confirmation(user)
    mail to: format_address_to(user)
  end

  def event_notification(user, event)
    @user = user
    @event = event

    mail to: format_address_to(user), subject: "You're invited: #{@event.title}"
  end

  def group_notification(user, group)
    @user = user
    @group = group

    mail to: format_address_to(user), subject: "You've been added: #{@group.title}"
  end

  def reminder_notification(user, reminder)
    @user = user
    @reminder = reminder

    mail to: format_address_to(user), subject: "#{@reminder.event.title} Reminder: #{@reminder.title}"
  end

  def nudge_notification(user, nudge)
    @user = user
    @nudge = nudge
    @event = @nudge.event

    mail to: format_address_to(user), subject: "#{@nudge.event.title}: #{@nudge.nudger.first_name} Nudged You"
  end

private
  def format_address_to(user)
    require 'mail'

    address = Mail::Address.new user.email
    address.display_name = user.name if user.name.present?
    address.format
  end
end
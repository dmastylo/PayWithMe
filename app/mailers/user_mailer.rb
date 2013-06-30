class UserMailer < ActionMailer::Base
  default from: "PayWithMe <#{Figaro.env.gmail_username}>"
  helper :application
  helper :users
  include UsersHelper
  layout 'mail'

  def signup_confirmation(user)
    return unless user.send_emails?

    mail to: format_address_to(user)
  end

  def event_notification(user, event)
    return unless user.send_emails?

    @user = user
    @event = event

    mail to: format_address_to(user), subject: "You're invited: #{@event.title}"
  end

  def group_notification(user, group)
    return unless user.send_emails?

    @user = user
    @group = group

    mail to: format_address_to(user), subject: "You've been added: #{@group.title}"
  end

  def reminder_notification(user, reminder)
    return unless user.send_emails?

    @user = user
    @reminder = reminder

    mail to: format_address_to(user), subject: "#{@reminder.event.title} Reminder: #{@reminder.title}"
  end

  def nudge_notification(user, nudge)
    return unless user.send_emails?
    
    @user = user
    @nudge = nudge
    @nudger = nudge.nudger
    @event = @nudge.event
    @organizer = @event.organizer

    mail to: format_address_to(user), subject: "#{user_name @nudger} wants you to pay for #{@nudge.event.title}"
  end

  def not_participating_notification(event_user, organizer)
    @event_user = event_user
    @user = event_user.user
    @event = event_user.event

    mail to: format_address_to(organizer), subject: "#{@event.title}: #{user_name @user} is Not Participating"
  end

  def unpaid_three_days_auto_email(user, event)
    @user = user
    @event = event

    mail to: format_address_to(user), subject: "There are three days left to pay for #{@event.title}."
  end

  def unpaid_one_day_auto_email(user, event)
    @user = user
    @event = event

    mail to: format_address_to(user), subject: "There is only one day left to pay for #{@event.title}!!"
  end

  def paid_three_days_auto_email(user, event)
    @user = user
    @event = event

    mail to: format_address_to(user), subject: "Help #{@event.organizer.first_name} get people to pay for #{@event.title}. There's three days left!"
  end

  def paid_one_day_auto_email(user, event)
    @user = user
    @event = event

    mail to: format_address_to(user), subject: "Help #{@event.organizer.first_name} get people to pay for #{@event.title}!! There's only one day left!"
  end

  def daily_update_to_organizer(organizer, event)
    @organizer = organizer
    @event = event
    
    mail to: format_address_to(organizer), subject: "Daily PayWithMe update on #{@event.title}"
  end

  def event_end_to_organizer(organizer, event)
    @organizer = organizer
    @event = event
    
    mail to: format_address_to(organizer), subject: "#{@event.title} has been completed!"
  end

private
  def format_address_to(user)
    require 'mail'

    address = Mail::Address.new user.email
    address.display_name = user.name if user.name.present?
    address.format
  end
end
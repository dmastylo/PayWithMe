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

    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')
    attachments.inline['visit_event.png'] = File.read('app/assets/images/visit_event.png')

    mail to: format_address_to(user), subject: "You're invited: #{@event.title}"
  end

  def group_notification(user, group)
    @user = user
    @group = group

    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')
    attachments.inline['visit_group.png'] = File.read('app/assets/images/visit_group.png')

    mail to: format_address_to(user), subject: "You've been added: #{@group.title}"
  end

private
  def format_address_to(user)
    require 'mail'

    address = Mail::Address.new user.email
    address.display_name = user.name if user.name.present?
    address.format
  end
end
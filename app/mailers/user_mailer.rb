class UserMailer < ActionMailer::Base
  default from: "PayWithMe <#{Figaro.env.gmail_username}>"
  helper :application

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.signup_confirmation.subject
  #
  def signup_confirmation(user)
    mail to: format_address_to(user)
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.event_notification.subject
  #
  def event_notification(user, event)
    @user = user
    @event = event

    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')
    attachments.inline['visit_event.png'] = File.read('app/assets/images/visit_event.png')

    mail to: format_address_to(user), subject: "You're invited: #{@event.title}"
  end

private
  def format_address_to(user)
    require 'mail'

    address = Mail::Address.new user.email
    address.display_name = user.name if user.name.present?
    address.format
  end
end
class MyDevise::Mailer < Devise::Mailer
  default from: "PayWithMe <#{Figaro.env.gmail_username}>"
  helper :application
  layout 'mail'

  def confirmation_instructions(record, opts={})
    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')

    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record, opts={})
    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')

    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record, opts={})
    attachments.inline['logo.png'] = File.read('app/assets/images/logo.png')
        
    devise_mail(record, :unlock_instructions, opts)
  end
end
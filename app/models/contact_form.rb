# == Schema Information
#
# Table name: contact_forms
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ContactForm < MailForm::Base
  
  attribute :name
  attribute :email 
  attribute :message
  attribute :nickname,  :captcha  => true

  validates :name, presence: true
  validates :email, presence: true, format: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i
  validates :message, presence: true

  # Declare the e-mail headers. It accepts anything the mail method
  # in ActionMailer accepts.
  def headers
    {
      :subject => "PayWithMe Contact Form",
      :to => "support@paywith.me",
      :from => %("#{name}" <#{email}>)
    }
  end
end

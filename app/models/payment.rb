# == Schema Information
#
# Table name: payments
#
#  id             :integer          not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  requested_at   :datetime
#  paid_at        :datetime
#  due_at         :datetime
#  payer_id       :integer
#  payee_id       :integer
#  event_id       :integer
#  amount_cents   :integer
#  event_user_id  :integer
#  transaction_id :string(255)
#

class Payment < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :payer_id, :payee_id, :event_id, :due_at, :requested_at, :paid_at, :event_user_id

  # Relationships
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"
  belongs_to :event
  belongs_to :event_user

  # Validations
  validates :payer_id, presence: true
  validates :payee_id, presence: true
  validates :event_id, presence: true
  validates :requested_at, presence: true
  validates :due_at, presence: true
  validates :event_user_id, presence: true

  # monetize :amount_cents

  def self.create_or_find_from_event_user(event_user)
    payment_attributes = {
      payer_id: event_user.member.id,
      payee_id: event_user.event.organizer.id,
      event_id: event_user.event.id
    }
    
    Payment.where(
      payment_attributes
    ).first || create(payment_attributes.merge(
      due_at: event_user.due_at,
      requested_at: event_user.event.created_at,
      event_user_id: event_user.id
    ))
  end

  def pay!
    recipients = [
      {
        email: Figaro.env.paypal_email,
        amount: event.our_fee_amount.to_f,
        primary: false
      },
      {
        email: payee.email,
        amount: event.send_amount.to_f,
        primary: true
      }
    ]

    gateway = Payment.gateway
    response = gateway.setup_purchase(
      return_url: Rails.application.routes.url_helpers.event_url(event_id),
      cancel_url: Rails.application.routes.url_helpers.event_url(event_id),
      ipn_notification_url: Rails.application.routes.url_helpers.ipn_event_user_url(event_user_id),
      receiver_list: recipients,
      fees_payer: "PRIMARYRECEIVER"
    )

    gateway.redirect_url_for(response["payKey"])
  end

private
  def self.gateway
    ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      login: Figaro.env.paypal_username,
      password: Figaro.env.paypal_password,
      signature: Figaro.env.paypal_signature,
      appid: Figaro.env.paypal_sandbox_appid
    )
  end
end

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
#  payment_method :integer
#

class Payment < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :error_message, :payer_id, :payee_id, :event_id, :payment_method, :amount_cents, :due_at, :requested_at, :event_user_id
  attr_accessor :error_message
  monetize :amount_cents, allow_nil: true

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
  validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }
  validates :payment_method, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2 }, if: :paid?
  validates :transaction_id, presence: true, if: :paid?

  def self.create_or_find_from_event_user(event_user, payment_method)
    payment_attributes = {
      payer_id: event_user.user.id,
      payee_id: event_user.event.organizer.id,
      event_id: event_user.event.id,
      payment_method: payment_method,
      amount_cents: event_user.event.split_amount_cents
    }
    
    Payment.where(
      payment_attributes
    ).first || create(payment_attributes.merge(
      due_at: event_user.due_at,
      requested_at: event_user.event.created_at,
      event_user_id: event_user.id
    ))
  end

  def paid?
    paid_at.present?
  end

  def pay!(options={})
    self.paid_at = Time.now
    self.transaction_id = "1234567890"
    self.payment_method = options[:payment_method] || PaymentMethod::MethodType::CASH
    self.save
    # if self.paid_at.present?
    #   self.error_message = "You have already paid!"
    #   return :back_to_event
    # end

    # if payment_method == PaymentMethod::MethodType::DWOLLA
    #   if pin.empty?
    #     self.error_message = "Please enter your pin."
    #     :back_to_pin
    #   else
    #     dwolla_user = Dwolla::User.me(event_user.user.dwolla_account.token)
    #     begin
    #       trans_id = dwolla_user.send_money_to(event_user.event.organizer.dwolla_account.uid, event.send_amount.to_f, pin, "Payment for #{event_user.event.title}", nil, event_user.event.members_pay?)
    #     rescue Exception => e
    #       self.error_message = e.message
    #       return :back_to_pin
    #     end
        
    #     self.transaction_id = trans_id
    #     self.event_user.paid_at = self.paid_at = Time.now
    #     self.event_user.save
    #     self.save
    #     :back_to_event
    #   end
    # else
      # Defaults to PayPal
      # recipients = [
      #   # {
      #   #   email: Figaro.env.paypal_email,
      #   #   amount: event.our_fee_amount.to_f,
      #   #   primary: false
      #   # },
      #   {
      #     email: payee.email,
      #     amount: event.send_amount.to_f
      #     # primary: true
      #   }
      # ]

      # gateway = Payment.paypal_gateway
      # response = gateway.setup_purchase(
      #   return_url: Rails.application.routes.url_helpers.event_url(event_id, success: 1),
      #   cancel_url: Rails.application.routes.url_helpers.event_url(event_id, cancel: 1),
      #   ipn_notification_url: Rails.application.routes.url_helpers.ipn_event_user_url(event_user_id),
      #   receiver_list: recipients,
      #   # fees_payer: "PRIMARYRECEIVER"
      # )

      # raise response.to_yaml

      # gateway.redirect_url_for(response["payKey"])
    # end
  end

  # Public because needed in another spot
  def self.dwolla_gateway
    Dwolla::Client.new(
      Figaro.env.dwolla_key,
      Figaro.env.dwolla_secret_key
    )
  end

private
  def self.paypal_gateway
    appid = Rails.env.production? ? Figaro.env.paypal_appid : Figaro.env.paypal_sandbox_appid
    ActiveMerchant::Billing::PaypalAdaptivePayment.new(
      login: Figaro.env.paypal_username,
      password: Figaro.env.paypal_password,
      signature: Figaro.env.paypal_signature,
      appid: appid
    )
  end
end

# == Schema Information
#
# Table name: payments
#
#  id                         :integer          not null, primary key
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  requested_at               :datetime
#  paid_at                    :datetime
#  due_at                     :datetime
#  payer_id                   :integer
#  payee_id                   :integer
#  event_id                   :integer
#  amount_cents               :integer
#  event_user_id              :integer
#  transaction_id             :string(255)
#  payment_method             :integer
#  processor_fee_amount_cents :integer
#  our_fee_amount_cents       :integer
#

class Payment < ActiveRecord::Base
  
  # Accessible attributes
  # There is no available create route right now so we
  # can get away with things that shouldn't be accessible
  attr_accessible :error_message, :payer_id, :payee_id, :event_id, :payment_method_id, :amount_cents, :processor_fee_amount_cents, :our_fee_amount_cents, :due_at, :requested_at, :event_user_id, :paid_at
  attr_accessor :error_message
  monetize :amount_cents, allow_nil: true
  monetize :processor_fee_amount_cents, allow_nil: true
  monetize :our_fee_amount_cents, allow_nil: true
  monetize :total_amount_cents, allow_nil: true

  # Relationships
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"
  belongs_to :event
  belongs_to :event_user
  belongs_to :payment_method

  # Validations
  validates :payer_id, presence: true
  validates :payee_id, presence: true
  validates :event_id, presence: true
  validates :requested_at, presence: true
  validates :due_at, presence: true
  validates :event_user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }
  validates :processor_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :our_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true, if: :paid?
  validates :transaction_id, presence: true, if: :paid_and_not_cash?

  # Callbacks
  before_validation :copy_event_attributes

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

  def paid_and_not_cash?
    paid? && payment_method_id != PaymentMethod::MethodType::CASH
  end

  def total_amount_cents
    (amount_cents || 0) + (processor_fee_amount_cents || 0) + (our_fee_amount_cents || 0)
  end

  def url
    if payment_method_id == PaymentMethod::MethodType::DWOLLA
      Rails.application.routes.url_helpers.pin_payment_path(self)
    elsif payment_method_id == PaymentMethod::MethodType::PAYPAL
      recipients = [
        # {
        #   email: Figaro.env.paypal_email,
        #   amount: event.our_fee_amount.to_f,
        #   primary: false
        # },
        {
          email: payee.paypal_account.email,
          amount: self.total_amount.to_s
          # primary: true
        }
      ]

      gateway = Payment.paypal_gateway
      response = gateway.setup_purchase(
        return_url: Rails.application.routes.url_helpers.event_url(self.event, success: 1),
        cancel_url: Rails.application.routes.url_helpers.event_url(self.event, cancel: 1),
        ipn_notification_url: Rails.application.routes.url_helpers.ipn_payment_url(self),
        receiver_list: recipients,
        # fees_payer: "PRIMARYRECEIVER"
      )

      # raise response.to_yaml

      gateway.redirect_url_for(response["payKey"])
    elsif payment_method_id == PaymentMethod::MethodType::WEPAY
      gateway = Payment.wepay_gateway
      response = gateway.call('/checkout/create', payee.wepay_account.token_secret,
      {
        account_id: payee.wepay_account.token,
        amount: self.amount.to_s,
        app_fee: self.our_fee_amount.to_s,
        short_description: "Payment for #{self.event.title}",
        type: "EVENT",
        redirect_uri: Rails.application.routes.url_helpers.event_url(self.event, success: 1),
        callback_uri: Rails.env.development?? nil : Rails.application.routes.url_helpers.ipn_payment_url(self)
      })

      self.transaction_id = response["checkout_id"]
      self.save

      response["checkout_uri"]
    end
  end

  def pay!(options={})
    self.transaction_id = options[:transaction_id]
    self.paid_at = Time.now
    self.save
  end

  def unpay!
    self.transaction_id = nil
    self.paid_at = nil
    self.save
  end

  # Public because needed in another spot
  def self.dwolla_gateway
    Dwolla::Client.new(
      Figaro.env.dwolla_key,
      Figaro.env.dwolla_secret_key
    )
  end

  def self.wepay_gateway
    if Rails.env.production?
      WePay.new(Figaro.env.wepay_client_id, Figaro.env.wepay_client_secret, _use_stage = false)
    else
      WePay.new(Figaro.env.wepay_sandbox_client_id, Figaro.env.wepay_sandbox_client_secret, _use_stage = true)
    end
  end

  def self.wepay_access_token
    if Rails.env.production?
      Figaro.env.wepay_access_token
    else
      Figaro.env.wepay_sandbox_access_token
    end
  end

private
  def self.paypal_gateway
    # if Rails.env.production?
    #   ActiveMerchant::Billing::PaypalAdaptivePayment.new(
    #     login: Figaro.env.paypal_username,
    #     password: Figaro.env.paypal_password,
    #     signature: Figaro.env.paypal_signature,
    #     appid: Figaro.env.paypal_appid
    #   )
    # else
      ActiveMerchant::Billing::PaypalAdaptivePayment.new(
        login: Figaro.env.paypal_sandbox_username,
        password: Figaro.env.paypal_sandbox_password,
        signature: Figaro.env.paypal_sandbox_signature,
        appid: Figaro.env.paypal_sandbox_appid
      )
    # end
  end

  def copy_event_attributes
    if self.event.present?
      self.requested_at = self.event.created_at
      self.due_at = self.event.due_at
    end

    if self.payment_method.present? && self.amount_cents.present?
      self.processor_fee_amount_cents = self.payment_method.processor_fee_after_our_fee(amount_cents)
      self.our_fee_amount_cents = self.payment_method.our_fee(amount_cents)
    end
  end
end

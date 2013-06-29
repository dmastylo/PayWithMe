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
#  processor_fee_amount_cents :integer
#  our_fee_amount_cents       :integer
#  payment_method_id          :integer
#  status                     :string(255)      default("new")
#  status_type                :integer
#

class Payment < ActiveRecord::Base
  
  # Accessible attributes
  # There is no available create route right now so we
  # can get away with things that shouldn't be accessible
  # ========================================================
  attr_accessible :error_message, :payer_id, :payee_id, :event_id, :payment_method_id, :amount, :amount_cents, :processor_fee_amount_cents, :our_fee_amount_cents, :due_at, :requested_at, :event_user_id, :paid_at, :item_users_attributes
  attr_accessor :error_message
  monetize :amount_cents, allow_nil: true
  monetize :processor_fee_amount_cents, allow_nil: true
  monetize :our_fee_amount_cents, allow_nil: true
  monetize :total_amount_cents, allow_nil: true

  # Relationships
  # ========================================================
  belongs_to :payer, class_name: "User"
  belongs_to :payee, class_name: "User"
  belongs_to :event
  belongs_to :event_user
  belongs_to :payment_method
  has_many :item_users, dependent: :destroy
  accepts_nested_attributes_for :item_users, allow_destroy: true

  # Validations
  # ========================================================
  validates :payer_id, presence: true
  validates :payee_id, presence: true
  validates :event_id, presence: true
  validates :requested_at, presence: true
  validates :due_at, presence: true
  validates :event_user_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :paid?
  validates :processor_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :our_fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :payment_method, presence: true, if: :paid?
  validates :transaction_id, presence: true, if: :paid_and_not_cash?

  # Callbacks
  # ========================================================
  before_validation :copy_event_attributes

  # Scopes
  # ========================================================
  def self.electronic
    Payment.where("payment_method_id != ?", PaymentMethod::MethodType::CASH)
  end

  def self.cash
    Payment.where(payment_method_id: PaymentMethod::MethodType::CASH)
  end

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
        {
          email: Figaro.env.paypal_email,
          amount: self.our_fee_amount.to_s,
          primary: false
        },
        {
          email: payee.paypal_account.email,
          amount: self.total_amount.to_s,
          primary: true
        }
      ]

      gateway = Payment.paypal_gateway
      response = gateway.setup_purchase(
        return_url: Rails.application.routes.url_helpers.event_url(self.event, success: 1),
        cancel_url: Rails.application.routes.url_helpers.event_url(self.event, cancel: 1),
        ipn_notification_url: Rails.application.routes.url_helpers.ipn_payment_url(self),
        receiver_list: recipients,
        fees_payer: "PRIMARYRECEIVER"
      )

      self.transaction_id = response["payKey"]
      self.save

      gateway.redirect_url_for(response["payKey"])
    elsif payment_method_id == PaymentMethod::MethodType::WEPAY
      gateway = Payment.wepay_gateway
      response = gateway.call('/checkout/create', payee.wepay_account.token_secret,
      {
        account_id: payee.wepay_account.token,
        amount: self.amount.to_s,
        app_fee: self.our_fee_amount.to_s,
        fee_payer: "Payer",
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
    self.destroy
  end

  # Handles the entire payment updating process from
  # updating the payment information from the processor
  # to marking the event_user as paid
  def update!
    return unless self.transaction_id.present? && self.event_user.present?

    if self.payment_method_id == PaymentMethod::MethodType::WEPAY
      gateway = Payment.wepay_gateway
      response = gateway.call('/checkout', self.payee.wepay_account.token_secret, { checkout_id: self.transaction_id })

      if response["error"].present?
        # Handle error
      else
        self.status = response["state"]
        update_status_type
        self.save

        if ["captured", "authorized"].include?(self.status)
          self.event_user.pay!(self, transaction_id: self.transaction_id)
        else
          # Something needs to be done here to handle cancelled and other states
          # self.event_user.unpay!(self)
        end
      end
    elsif self.payment_method_id == PaymentMethod::MethodType::PAYPAL
      gateway = Payment.paypal_gateway
      response = gateway.details_for_payment({ pay_key: self.transaction_id })

      if response.error.present?
        # Handle error
      else
        self.status = response.status.downcase
        update_status_type
        self.save

        if self.status == "completed"
          self.event_user.pay!(self, transaction_id: self.transaction_id)
        else
          # Something needs to be done here to handle cancelled and other states
          # self.event_user.unpay!(self)
        end
      end

    elsif self.payment_method_id == PaymentMethod::MethodType::DWOLLA
      # Dwolla will soon be removed

      dwolla_user = Dwolla::User.me(self.payer.dwolla_account.token)

      begin
        response = dwolla_user.transaction(self.transaction_id)

        self.status = response["Status"].downcase
        self.save

        if self.status == "processed"
          self.event_user.pay!(self, transaction_id: self.transaction_id)
        else
          # Something needs to be done here to handle cancelled and other states
          # self.event_user.unpay!(self)
        end
      rescue Exception => e
        # Handle error
      end
    end
  end

  def update_status_type
    if self.payment_method_id == PaymentMethod::MethodType::WEPAY
      if self.status == "new"
        self.status_type = StatusType::PENDING
      elsif ["authorized", "captured", "settled"].include?(self.status)
        self.status_type = StatusType::PAID
      elsif ["cancelled", "refunded", "charged back", "failed"].include?(self.status)
        self.status_type = StatusType::CANCELLED
      elsif self.status == "expired"
        self.status_type = StatusType::EXPIRED
      end
    elsif self.payment_method_id == PaymentMethod::MethodType::PAYPAL
      if self.status == "created"
        self.status_type = StatusType::PENDING
      elsif self.status == "approved"
        self.status_Type = StatusType::PAID
      elsif ["failed", "cancelled"].include?(self.status)
        self.status_type = StatusType::CANCELLED
      elsif self.status == "expired"
        self.status_type = StatusType::EXPIRED
      end
    end
  end

  # Returns truthy value if update works, otherwise falsey
  def update_for_items!
    total_amount_cents = 0
    self.item_users.each do |item_user|
      item = item_user.item
      if item.allow_quantity?
        if item_user.quantity >= item.quantity_min && item_user.quantity <= item.quantity_max
          item_user.total_amount_cents = item.amount_cents * item_user.quantity
        else
          return false
        end
      else
        item_user.total_amount_cents = item.amount_cents
        item_user.quantity = 1
      end
      total_amount_cents += item_user.total_amount_cents
      item_user.save
    end

    if total_amount_cents == 0
      return false
    end

    self.amount_cents = total_amount_cents
    update_fees
    self.save
    self.reload
    true
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

  # Constants
  # ========================================================
  class StatusType
    PENDING = 1
    PAID = 2
    CANCELLED = 3
    EXPIRED = 4
  end

  # Statistics
  # ========================================================
  def self.total_revenue
    payments = Payment.where("payment_method_id != ? AND status_type = ?", PaymentMethod::MethodType::CASH, StatusType::PAID)
    (payments.count * 0.80) + (payments.sum('amount_cents') * 0.04) / 100 # since we are grabbing the cent values
  end

  def self.total_payments
    payments = Payment.where("status_type = ?", StatusType::PAID)
    total_payments_made_count = payments.count
    total_payments_made_value = payments.sum('amount_cents')

    {
      "count" => total_payments_made_count,
      "value" => total_payments_made_value / 100.0 # since we are grabbing the cent values
    }
  end

  def self.total_cash_payments
    payments = Payment.where("payment_method_id = ? AND status_type = ?", PaymentMethod::MethodType::CASH, StatusType::PAID)
    total_payments_made_count = payments.count
    total_payments_made_value = payments.sum('amount_cents')

    {
      "count" => total_payments_made_count,
      "value" => total_payments_made_value / 100.0 # since we are grabbing the cent values
    }
  end

  def self.total_electronic_payments
    payments = Payment.where("payment_method_id != ? AND status_type = ?", PaymentMethod::MethodType::CASH, StatusType::PAID)
    total_payments_made_count = payments.count
    total_payments_made_value = payments.sum('amount_cents')

    {
      "count" => total_payments_made_count,
      "value" => total_payments_made_value / 100.0 # since we are grabbing the cent values
    }
  end

private
  def self.paypal_gateway
    if Rails.env.production?
      ActiveMerchant::Billing::PaypalAdaptivePayment.new(
        login: Figaro.env.paypal_username,
        password: Figaro.env.paypal_password,
        signature: Figaro.env.paypal_signature,
        appid: Figaro.env.paypal_appid
      )
    else
      ActiveMerchant::Billing::PaypalAdaptivePayment.new(
        login: Figaro.env.paypal_sandbox_username,
        password: Figaro.env.paypal_sandbox_password,
        signature: Figaro.env.paypal_sandbox_signature,
        appid: Figaro.env.paypal_sandbox_appid
      )
    end
  end

  def copy_event_attributes
    if self.event.present?
      self.requested_at = self.event.created_at
      self.due_at = self.event.due_at
    end

    update_fees
  end

  def update_fees
    if self.payment_method.present? && self.amount_cents.present?
      self.processor_fee_amount_cents = self.payment_method.processor_fee(amount_cents)
      self.our_fee_amount_cents = self.payment_method.our_fee(amount_cents)
    end
  end
end

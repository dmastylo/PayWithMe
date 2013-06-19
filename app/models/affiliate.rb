# == Schema Information
#
# Table name: affiliates
#
#  id             :integer          not null, primary key
#  name           :string(255)
#  school         :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  affiliate_type :integer
#

class Affiliate < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :name, :school

  # Relationships
  # ========================================================
  has_many :referrals, class_name: "User", foreign_key: "referrer_id"

  # Validations
  # ========================================================
  validates :name, presence: true
  validates :school, presence: true, unless: :company?

  # Constants
  # ========================================================
  class AffiliateType
    CAMPUS_REP = 1
    COMPANY = 2
  end

  # Affiliate types
  # ========================================================
  def campus_rep?
    affiliate_type == AffiliateType::CAMPUS_REP
  end

  def company?
    affiliate_type == AffiliateType::COMPANY
  end

  # Static functions
  # ========================================================
  def self.list_of_reps
    Affiliate.all.collect do |c|
      if c.campus_rep?
        [c.name + " from " + c.school, c.id] 
      else
        [c.name, c.id] 
      end
    end
  end

  # Statistics
  # ========================================================
  # TODO: These need to be optimized at some point
  def amount_of_referred_events
    referred_events_count = 0
    referrals.each do |referral|
      referred_events_count += referral.organized_events.count
    end

    referred_events_count
  end

  def amount_of_electronic_payments
    total_amount_made = 0
    referrals.each do |referral|
      total_amount_made += Payment.where("payee_id = ? AND payment_method_id != ?", referral.id, PaymentMethod::MethodType::CASH).count
    end

    total_amount_made
  end

  def value_of_electronic_payments
    # Payment.count(:conditions => "payment_method_id != #{PaymentMethod::MethodType::CASH} AND payee.referrer_id = #{self.id}", :include => :payee)

    total_value_made = 0
    referrals.each do |referral|
      total_value_made += Payment.where("payee_id = ? AND payment_method_id != ?", referral.id, PaymentMethod::MethodType::CASH).sum('amount_cents')
    end

    total_value_made
  end

  def made_this_month
    # Payment.count(:conditions => "payment_method_id != #{PaymentMethod::MethodType::CASH} AND payee.referrer_id = #{self.id}", :include => :payee)

    total_value_made_this_month = 0
    referrals.each do |referral|
      total_value_made_this_month += Payment.where("payee_id = ? AND payment_method_id != ?", referral.id, PaymentMethod::MethodType::CASH).sum('amount_cents')
    end

    total_value_made_this_month
  end

end

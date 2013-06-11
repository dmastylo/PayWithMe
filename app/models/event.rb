# == Schema Information
#
# Table name: events
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  description            :text
#  due_at                 :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  collection_type        :integer
#  total_cents            :integer
#  per_person_cents       :integer
#  organizer_id           :integer
#  privacy_type           :integer
#  slug                   :string(255)
#  image_file_name        :string(255)
#  image_content_type     :string(255)
#  image_file_size        :integer
#  image_updated_at       :datetime
#  image_url              :string(255)
#  guest_token            :string(255)
#  send_tickets           :boolean          default(FALSE)
#  location_title         :string(255)
#  location_address       :string(255)
#  donation_goal_cents    :integer
#  minimum_donation_cents :integer
#

class Event < ActiveRecord::Base

  # Attributes
  attr_accessible :title, :description, :due_at, :collection_type, :privacy_type, :image_url,
    # Currency attributes - don't touch *_cents
    :total, :per_person, :donation_goal, :minimum_donation,
    # Virtual attributes
    :due_at_date, :due_at_time, :image_type, :items_attributes
  attr_accessor :due_at_date, :due_at_time, :image_type, :invitation_group
  [:total, :per_person, :donation_goal, :collected, :minimum_donation].each do |field| monetize "#{field}_cents", allow_nil: true end
  has_attached_file :image

  # Validations
  validates :organizer_id, presence: true
  validates :collection_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 4, message: "is an invalid collection type" }
  validates :privacy_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 2, message: "is an invalid privacy type" }
  validates :title, presence: true, length: { minimum: 2, maximum: 120, message: "has to be between 2 and 120 characters long" }
  validates :due_at, presence: true
  validates :due_at, date: { after: Proc.new { Time.now }, message: "can't be in the past" }, if: :due_at_changed?
  validates :total, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :collecting_by_total?
  validates :per_person, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :collecting_by_person?
  validates :donation_goal, presence: true, numericality: { greater_than: 0, message: "must have a positive dollar amount" }, if: :collecting_by_donation?
  validates :minimum_donation, numericality: { greater_than_or_equal_to: 0, message: "must have be 0 or higher dollar amount" }, :allow_nil => true, if: :collecting_by_donation?
  validate :amounts_not_changed, on: :update, if: :received_money?

  # Relationships
  belongs_to :organizer, class_name: "User"
  has_many :event_users, dependent: :destroy
  has_many :members, class_name: "User", through: :event_users, source: :user, before_add: :handle_member_add, before_remove: :handle_member_remove
  has_many :messages, dependent: :destroy
  has_many :event_groups, dependent: :destroy
  has_many :groups, through: :event_groups, source: :group
  has_many :reminders, dependent: :destroy
  has_many :nudges, dependent: :destroy
  has_many :items, dependent: :destroy
  accepts_nested_attributes_for :items, allow_destroy: true
  has_many :invitation_types, dependent: :destroy
  has_many :item_users
  has_many :payments

  # Callbacks
  before_validation :clear_amounts
  before_validation :concatenate_dates
  before_save :clear_dates
  before_save :set_event_image
  before_save :add_organizer_to_members
  before_destroy :clear_notifications_and_news_items
  after_save :create_guest_token

  # Pretty URLs
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

  # Dynamic methods
  def method_missing(name, *arguments, &block)
    if name =~ /^collecting_by_([a-z]+)\?/
      # Defines colleciton_by_total?, collection_by_person?, collecting_by_donation?, collecting_by_item?
      return collection_type == Collection.const_get("#{$1}".upcase)
    end
  end
  def respond_to?(name, include_private=false)
    if name =~ /^collecting_by/
      true
    else
      super
    end
  end

  # Money definitions
  def total_cents
    if collecting_by_total?
      super # Retrieve from the database
    elsif empty? || per_person_cents_missing? || not_using_total?
      nil
    else
      per_person_cents * paying_members.count
    end
  end
  def per_person_cents
    if collecting_by_person?
      super # Retrieve from the database
    elsif empty? || total_cents_missing? || not_using_total?
      nil
    else
      total_cents / paying_members.count
    end
  end
  def collected_cents
    # TODO: Payments are linked to events, use that instead
    Payment.where("event_user_id IN (?) AND paid_at IS NOT NULL", self.event_user_ids).sum(&:amount_cents)
  end
  def accepts_donation?(amount_cents) # Should this be in cents or dollars?
    amount_cents >= minimum_donation_cents
  end
  def paid_percent
    if self.collected > 0
      if self.collecting_by_donation?
        100.0 * (self.collected / self.donation_goal)
      else
        100.0 * (self.collected / self.total)
      end
    else
      0
    end
  end
  
  # Collection/privacy types
  def not_using_total? # Disactivates attributes total and per_person for these collection types
    collecting_by_donation? || collection_by_items?
  end
  def public?
    privacy_type == Privacy::PUBLIC
  end
  def private?
    privacy_type == Privacy::PRIVATE
  end
  def share_link?
    self.invitation_type_ids.include?(InvitationType::Type::LINK)
  end

  # Constants
  class Collection
    TOTAL = 1
    PERSON = 2
    DONATION = 3
    ITEM = 4
  end
  class Privacy
    PUBLIC = 1
    PRIVATE = 2
  end

  # Virtual attributes
  def due_at_date
    if @due_at_date.present?
      @due_at_date
    elsif due_at.present?
      due_at.to_date.to_s
    end
  end
  def due_at_time
    if @due_at_time.present?
      @due_at_time
    elsif due_at.present?
      due_at.strftime('%I:%M%p')
    end
  end
  def image_type
    if @image_type.present?
      @image_type
    elsif image.present?
      :upload
    elsif image_url.present?
      :url
    else
      :default_image
    end
  end

  # Member definitions
  # Three states: paying, paid, unpaid
  has_many :paying_event_users, class_name: "EventUser", conditions: proc { ["event_users.user_id <> ? ", organizer_id ]}
  has_many :paying_members, class_name: "User", through: :paying_event_users, source: :user
  has_many :paid_event_users, class_name: "EventUser", conditions: proc { ["event_users.paid_at IS NOT NULL AND event_users.user_id <> ?", organizer_id ]}
  has_many :paid_members, class_name: "User", through: :paid_event_users, source: :user
  has_many :unpaid_event_users, class_name: "EventUser", conditions: proc { ["event_users.paid_at IS NULL AND event_users.user_id <> ?", organizer_id] }
  has_many :unpaid_members, class_name: "User", through: :unpaid_event_users, source: :user

  def empty?
    self.paying_event_users.empty?
  end
  def invited?(user)
    members.include?(user)
  end

  # Notifications, emails, and news items
  def update_members(&block)
    self.invitation_group = event_users.maximum(:invitation_group) + 1
    block.call
  end
  def self.queue_broadcasts(event_id, broadcasts=[:invitations, :tickets, :guests, :messages])
    event = Event.find_by_id(event_id, include: { event_users: :user })
    if event.present?
      broadcasts.each do |method| event.send("broadcast_#{method}") end
    end
  end
  def broadcast_invitations
    event_users.each do |event_user|
      if !event_user.sent_invitation_email? && event_user.user_id != organizer_id
        event_user.user.create_guest_token if event_user.user.stub?
        UserMailer.send_for_event_invitation(self, event_user.user).deliver
        Notification.create_for_event_invitation(self.id, event_user.user_id)
        event_user.toggle(:sent_invitation_email).save
      end
    end
  end
  def broadcast_tickets
    # event_users.each do |event_user|
    #   if !event_user.sent_ticket_email? && event_user.paid?
    #   end
    # end
  end
  def broadcast_guests
    event_users.each do |event_user|
      if !event_user.sent_guest_broadcast?
        event_user.toggle(:sent_guest_broadcast)
      end
    end
  end
  def broadcast_messages
  end

  # def send_message_notifications
  #   event = Event.find_by_id(event_id, include: :members)
  #   Notification.create_or_update_for_event_message(event, event.member_ids)
  # end

  def independent_members
    nfgdi_members = self.paying_members

    self.groups.each do |group|
      nfgdi_members -= group.members
    end

    nfgdi_members
  end

  def invitation_type_ids
    self.invitation_types.collect { |invitation_type| invitation_type.invitation_type }
  end

  # TODO: Refactor these methods
  def event_user_of(user)
    event_users.find_by_user_id(user)
  end

  def paid?(user)
    event_user = event_user_of(user)
    event_user.present? && event_user.paid?
  end

  def paid_with_cash?(user)
    event_user = event_user_of(user)
    event_user.paid_with_cash?
  end

  def paid_at(user)
    event_user_of(user).paid_at
  end

  def received_money?
    paid_members.count > 0
  end

  # Nudges
  def can_nudge?(nudger, nudgee, nudger_event_user=nil, nudgee_event_user=nil)
    if nudger_event_user.nil?
      nudger_event_user = self.event_user_of(nudger)
    end

    if nudgee_event_user.nil?
      nudgee_event_user = self.event_user_of(nudgee)
    end

    if !invited?(nudger) ||
      !invited?(nudgee) ||
      nudger_event_user.status == EventUser::Status::UNPAID ||
      nudgee_event_user.paid_at.present? ||
      nudgee == self.organizer ||
      nudger_event_user.nudges_remaining <= 0 ||
      self.nudges.where(nudgee_id: nudgee.id, nudger_id: nudger.id).count > 0
      false
    else
      true
    end
  end

  def nudge!(nudger, nudgee)
    if can_nudge?(nudger, nudgee)
      nudges.create!(nudger_id: nudger.id, nudgee_id: nudgee.id, event_id: self.id)
    end
  end

  def nudges_remaining(nudger)
    Figaro.env.nudge_limit.to_i - nudger.sent_nudges.find_all_by_event_id(self.id).count
  end

  def has_nudged?(nudger, nudgee)
    self.nudges.where(nudgee_id: nudgee.id, nudger_id: nudger.id).count > 0
  end
  
  def is_past?
    Time.now > self.due_at
  end

private
  def clear_amounts
    self.per_person = nil unless collecting_by_person?
    self.total = nil unless collecting_by_total?
    self.donation_goal = nil unless collecting_by_donation?
    self.items = [] unless collecting_by_item?
    self.items_attributes = [] unless collecting_by_item?
  end

  def concatenate_dates
    self.due_at = "#{self.due_at_date} #{self.due_at_time}"
  end

  def clear_dates
    due_at_date = due_at_time = nil
  end

  def set_event_image
    return unless self.image_type.present?

    if self.image_type != "url"
      self.image_url = nil
    end

    if self.image_type != "upload"
      self.image = nil
    end

    image_type = nil
  end
  
  def add_organizer_to_members
    if !members.include?(organizer)
      members << organizer
    end
  end

  def amounts_not_changed
    if collecting_by_total? && total_cents_changed?
      errors.add(:total, "cannot be changed after a member has paid")
    end

    if divide_per_person? && per_person_cents_changed?
      errors.add(:per_person, "cannot be changed after a member has paid")
    end
  end

  def clear_notifications_and_news_items
    Notification.where(foreign_id: self.id, foreign_type: Notification::ForeignType::EVENT).destroy_all
    NewsItem.where(foreign_id: self.id, foreign_type: NewsItem::ForeignType::EVENT).destroy_all
  end

  def create_guest_token
    if self.guest_token.nil? && self.invitation_type_ids.include?(InvitationType::Type::LINK)
      self.guest_token = ::BCrypt::Password.create("#{self.title}#{self.created_at}")
      self.save
    end
  end
end
# == Schema Information
#
# Table name: reminders
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string(255)
#  body           :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  recipient_type :integer
#

class Reminder < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :body, :title, :recipient_type

  # Validations
  validates :body, presence: true
  validates :title, presence: true
  validates :recipient_type, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 3 }
  validates :event_id, presence: true

  # Relationships
  belongs_to :event
  has_many :reminder_users, dependent: :destroy
  has_many :users, through: :reminder_users

  # Constants
  class RecipientType
    ALL = 1
    UNPAID = 2
    PAID = 3
  end

  def all?
    recipient_type == RecipientType::ALL
  end

  def unpaid?
    recipient_type == RecipientType::UNPAID
  end

  def paid?
    recipient_type == RecipientType::PAID
  end

  def add_users(users, exclude_from_reminders=nil)
    users.each do |user|
      if user != exclude_from_reminders && !self.users.include?(users)
        self.users << user
      end
    end
  end

  def self.send_emails(reminder_id)
    @reminder = Reminder.find(reminder_id)
    if @reminder.present?
      @reminder.reminder_users.each do |reminder_user|
        unless reminder_user.sent?
          UserMailer.reminder_notification(reminder_user.user, @reminder).deliver
          reminder_user.toggle(:sent).save
        end
      end
    end
  end

end
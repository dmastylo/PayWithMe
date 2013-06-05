# == Schema Information
#
# Table name: item_users
#
#  id                 :integer          not null, primary key
#  item_id            :integer
#  user_id            :integer
#  event_user_id      :integer
#  payment_id         :integer
#  event_id           :integer
#  quantity           :integer
#  total_amount_cents :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ItemUser < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :event_id, :event_user_id, :item_id, :payment_id, :quantity, :total_cents, :user_id

  # Relationships
  belongs_to :item
  belongs_to :user
  belongs_to :event_user
  belongs_to :payment
  belongs_to :event

end

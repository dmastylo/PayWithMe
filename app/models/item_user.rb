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
  attr_accessible :event_id, :event_user_id, :item_id, :payment_id, :quantity, :total_amount_cents, :user_id
end

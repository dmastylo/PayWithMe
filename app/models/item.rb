# == Schema Information
#
# Table name: items
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  event_id       :integer
#  amount_cents   :integer
#  allow_quantity :boolean
#  quantity_min   :integer
#  quantity_max   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Item < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :allow_quantity, :amount_cents, :quantity_max, :quantity_min, :title

  # Relationships
  belongs_to :event

end

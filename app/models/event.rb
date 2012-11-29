# == Schema Information
#
# Table name: events
#
#  id                     :integer          not null, primary key
#  title                  :string(255)
#  description            :text
#  amount_cents           :integer          default(0)
#  due_on                 :date
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  start_at               :datetime
#  division               :string(255)
#  payment_division       :string(255)
#  payment_division_fees  :string(255)
#  payment_division_total :string(255)
#

class Event < ActiveRecord::Base
  attr_accessible :amount_cents, :amount, :description, :due_on, :start_at, :title
  monetize :amount_cents
end

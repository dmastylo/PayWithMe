# == Schema Information
#
# Table name: cards
#
#  id               :integer          not null, primary key
#  account_id       :integer
#  uri              :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  brand            :string(255)
#  expiration_month :integer
#  expiration_year  :integer
#

class Card < ActiveRecord::Base
  attr_accessible :brand, :expiration_month, :expiration_year, :uri

  # Relationships
  belongs_to :account

end

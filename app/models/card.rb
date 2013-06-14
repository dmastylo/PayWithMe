# == Schema Information
#
# Table name: cards
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uri        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Card < ActiveRecord::Base

  attr_accessible :brand, :expiration_month, :expiration_year, :uri

end
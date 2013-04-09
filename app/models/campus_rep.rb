# == Schema Information
#
# Table name: campus_reps
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  school     :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CampusRep < ActiveRecord::Base

  # Accessible attributes
  # ========================================================
  attr_accessible :name, :school

  # Relationships
  # ========================================================
  has_many :referrals, class_name: "User", foreign_key: "referrer_id"

  # Static functions
  # ========================================================
  def self.list_of_reps
    CampusRep.all.collect { |c| [c.name + " from " + c.school, c.id] }
  end

end

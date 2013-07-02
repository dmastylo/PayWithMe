# == Schema Information
#
# Table name: invitation_types
#
#  id              :integer          not null, primary key
#  invitation_type :integer
#  event_id        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class InvitationType < ActiveRecord::Base

  # Accessible attributes
  attr_accessible :event_id, :invitation_type

  # Relationships
  belongs_to :event

  def self.from_params(params)
    invitation_types = ActiveSupport::JSON.decode(params || "[]")
    invitation_types.map { |i| InvitationType.new(invitation_type: i) }
  end

  class Type
    EMAIL = 1
    LINK = 2
    GROUP = 3
  end

end
# == Schema Information
#
# Table name: contacts
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Contact < ActiveRecord::Base

  # Attr Accessible
  attr_accessible :email, :name, :user_id

  # Scope
  default_scope order('name ASC')

end

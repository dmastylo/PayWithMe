# == Schema Information
#
# Table name: linked_accounts
#
#  id           :integer          not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  provider     :string(255)
#  uid          :string(255)
#  token        :string(255)
#  user_id      :integer
#  token_secret :string(255)
#

require 'spec_helper'

describe LinkedAccount do
  pending "add some examples to (or delete) #{__FILE__}"
end

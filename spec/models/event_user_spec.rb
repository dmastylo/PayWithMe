# == Schema Information
#
# Table name: event_users
#
#  id              :integer          not null, primary key
#  event_id        :integer
#  user_id         :integer
#  amount_cents    :integer          default(0)
#  due_date        :date
#  paid_date       :date
#  invitation_sent :bool
#

require 'spec_helper'

describe EventUser do
  pending "add some examples to (or delete) #{__FILE__}"
end

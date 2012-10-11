class Notification < ActiveRecord::Base
  attr_accessible :body, :type, :user_id
end

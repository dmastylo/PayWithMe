# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0)
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :string(255)
#  last_sign_in_ip            :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  name                       :string(255)
#  provider                   :string(255)
#  uid                        :string(255)
#  profile_image_file_name    :string(255)
#  profile_image_content_type :string(255)
#  profile_image_file_size    :integer
#  profile_image_updated_at   :datetime
#  profile_image_url          :string(255)
#

require 'spec_helper'

describe User do
	
	before do
		@user = User.new(name: "John Sample", 
						 email: "test2@example.com", 
						 password: "foobar", 
						 password_confirmation: "foobar")
 	end

	subject { @user }

 	describe "when a password is too short" do
 		before{ @user.password = @user.password_confirmation = "x" * 7 }
 		it{ should be_invalid }
 	end

 	describe "when a password doesn't match confirmation" do
 		before{ @user.password_confirmation = "Mismatch" }
 		it{ should be_invalid }
 	end

 	after do
 		@user.destroy
 	end
end

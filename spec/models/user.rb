# require 'spec_helper'

# describe User do
#   before { @user = User.new(name: "Lorem Ipsum", email: "lorem@ipsum.com", password: "foobar", password_confirmation: "foobar") }
#   subject { @user }

#   describe "profile_image_option method" do
#     it { should respond_to(:profile_image_option) }

#     describe "with nil profile_image" do
#       # @user.profile_image is initially nil
#       it "should return gravatar" do
#         @user.profile_image_option.should == :gravatar
#       end
#     end

#     describe "with local URL" do
#       before do
#         # @user.profile_image = "http://#{request.host}/uploads/profile_images/image.png"
#       end

#       it "should return upload" do
#         @user.profile_image_option.should == :upload
#       end
#     end

#     describe "with seemingly local URL" do
#       before do
#         # @user.profile_image = "http://#{request.host}.uk/uploads/profile_images/image.png"
#       end

#       it "should return upload" do
#         @user.profile_image_option.should_not == :upload
#         @user.profile_image_option.should == :url
#       end
#     end

#     describe "with remote URL" do
#       before do
#         # @user.profile_image = "http://google.com/uploads/profile_images/image.png"
#       end

#       it "should return upload" do
#         @user.profile_image_option.should == :url
#       end
#     end
#   end
# end
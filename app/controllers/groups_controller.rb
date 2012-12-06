class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_in_group, only: [:show]

  def new
    @group = Group.new
  end

  def create
    members = ActiveSupport::JSON.decode(params[:group].delete(:members))
    @group = Group.new(params[:group])
    members.each do |member|
      user = User.find_by_email(member)
      if user.nil?
        user = User.new(email: member)
        user.stub = true
        user.save
      end

      @group.members << user
    end
    @group.members << current_user

    if @group.save
      flash[:success] = "Group created!"

      group_owner = current_user.group_users.where(group_id: @group.id).first
      group_owner.admin = true
      group_owner.save

      redirect_to group_path(@group)
    else
      render "new"
    end
  end

  def edit
  end

  def update
  end

  def index
  end

  def show
  end

private
  def user_in_group
    @group = Group.find(params[:id])

    if @group.members.include?(current_user)
      true
    else
      flash[:error] = "You're not on the list."
      redirect_to root_path
    end
  end
end

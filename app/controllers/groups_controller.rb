class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_group, only: [:show]
  before_filter :user_organizes_group, only: [:edit, :update, :delete, :destroy]

  def index
    @groups = current_user.member_groups
  end

  def show
    if request.path != group_path(@group)
      redirect_to group_path(@group), status: :moved_permanently
    end
  end

  def new
    @group = Group.new
  end

  def create
    members = User.from_params(params[:group].delete(:members))
    @group = Group.new(params[:group])

    if @group.save
      flash[:success] = "Group created!"

      @group.add_members(members + [current_user], current_user)
      
      group_owner = current_user.group_users.where(group_id: @group.id).first
      group_owner.admin = true
      group_owner.save

      redirect_to group_path(@group)
    else
      @member_emails = @group.members.collect { |member| member.email }
      render "new"
    end
  end

  def edit
    @member_emails = @group.members.collect { |member| member.email }
  end

  def update
    members = User.from_params(params[:group].delete(:members))

    if @group.update_attributes(params[:group])
      flash[:success] = "Group updated!"

      @group.set_members(members + [current_user])

      redirect_to group_path(@group)
    else
      @member_emails = @group.members.collect { |member| member.email }
      render "edit"
    end
  end

  def destroy
    @group.destroy
    flash[:success] = "Group deleted!"
    redirect_to groups_path
  end

  def search
    @query = params[:name]
    if @query.nil? || @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @groups = Group.search_by_title(@query, current_user)
    end
    @groups ||= []

    respond_to do |format|
      format.html
      format.json do
        @groups = @groups.collect { |result| {id: result.id, title: result.title } }
        render json: @groups
      end
    end
  end
end

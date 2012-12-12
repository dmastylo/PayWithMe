class GroupsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_not_stub, only: [:new, :create]
  before_filter :user_in_group, only: [:show]

  def new
    @group = Group.new
  end

  def create
    members = User.from_params(params[:group].delete(:members))
    @group = Group.new(params[:group])
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
    @groups = current_user.groups
  end

  def show
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

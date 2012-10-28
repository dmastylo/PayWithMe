class UsersController < ApplicationController

  # Before Filters
  before_filter :authenticate_user!
  # TODO: Make finding the user a before_filter

  def show
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      @payment = current_user.expected_payments.new
    end
  end

  def friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.send_friend_request!(@user)
      @user.notifications.create(category: "friend", body: "#{current_user.name} has sent you a friend request", foreign_id: current_user.id, read: 0)
      redirect_to @user
    end
  end

  def accept_friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.accept_friend!(@user)
      @user.notifications.create(category: "friend", body: "#{current_user.name} has accepted your friend request", foreign_id: current_user.id, read: 0)
      redirect_to @user
    end
  end

  def deny_friend
    @user = User.find_by_id(params[:id])
    if @user.nil?
      render "notfound"
    else
      current_user.deny_friend!(@user)
      redirect_to @user
    end
  end

  def search_friends
    @query = params[:name]
    if @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @users = current_user.find_friends_by_name(@query)
    end

    respond_to do |format|
      format.html
      format.json do
        @users = @users.collect { |result| {id: result.id, name: result.name} }
        render json: @users
      end
    end
  end

  # Search all users
  def search
    @query = params[:name]
    if @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @users = User.paginate(page: params[:page], per_page: 15).search_by_name(@query)
      @users = @users.reject { |result| result == current_user }
    end
    
    respond_to do |format|
      format.html
      format.json do
        @users = @users.collect { |result| {id: result.id, name: result.name} }
        render json: @users
      end
    end
  end

  def read_notifications
    current_user.notifications.each do |notification|
      notification.read = 1
      notification.save
    end

    render nothing: true
  end

  def settings

  end

  def update_settings

  end

end
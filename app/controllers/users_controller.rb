class UsersController < ApplicationController
  before_filter :authenticate_user!

  def show
  end

  def search
    @query = params[:name]
    if @query.nil? || @query.empty?
      flash.now[:error] = "Please enter a search term."
    else
      @users = User.search_by_name(@query)
      @users = @users.reject { |result| result == current_user }
    end
    @users ||= []

    respond_to do |format|
      format.html
      format.json do
        @users = @users.collect { |result| {id: result.id, name: result.name, profile_image: view_context.profile_image_tag(result) } }
        render json: @users
      end
    end
  end

end
class LinkedAccountsController < ApplicationController

  # Before Filters
  before_filter :authenticate_user!
  before_filter :correct_user_to_delete

  def destroy
    @account.destroy
    flash[:success] = "Account successfully unlinked."
    redirect_to users_settings_path
  end

private

  def correct_user_to_delete
    @account = current_user.linked_accounts.find_by_id(params[:id])
    redirect_to users_settings_path if !@account
  end

end

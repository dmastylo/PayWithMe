class LinkedAccountsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_owns_linked_account

  def destroy
    if current_user.linked_accounts.count > 1 || current_user.encrypted_password.present?
      @linked_account.destroy
      flash[:success] = "#{@linked_account.provider.humanize} account successfully unlinked!"
    else
      flash[:error] = "You need to keep at least one linked account in order to sign in."
    end
    redirect_to edit_user_registration_path
  end

private
  def user_owns_linked_account
    @linked_account = current_user.linked_accounts.find_by_id(params[:id])
    redirect_to root_path unless @linked_account.present?
  end
end
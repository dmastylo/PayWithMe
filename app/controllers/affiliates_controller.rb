class AffiliatesController < ApplicationController
  before_filter :user_is_admin
  before_filter :find_affiliate, only: [:show, :edit, :update, :destroy]

  def show
    @referrals = @affiliate.referrals.paginate(page: params[:page], per_page: 20)
  end

  def new
    @affiliate = Affiliate.new
  end

  def create
    @affiliate = Affiliate.new(params[:affiliate])

    if @affiliate.save
      flash[:notice] = "Affiliate added."
      redirect_to admin_index_path
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    if @affiliate.update_attributes(params[:affiliate])
      flash[:success] = "Affiliate updated."
      redirect_to affiliates_admin_index_path
    else
      render "edit"
    end
  end

  def destroy
    @affiliate.destroy
    flash[:success] = "Affiliate deleted!"
    redirect_to admin_index_path
  end

private
  def find_affiliate
    @affiliate = Affiliate.find(params[:id])
  end
end

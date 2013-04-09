class CampusRepsController < ApplicationController
  before_filter :user_is_admin

  def new
    @campus_rep = CampusRep.new
  end

  def create
    @campus_rep = CampusRep.new(params[:campus_rep])

    if @campus_rep.save
      flash[:notice] = "Campus rep added."
      redirect_to admin_index_path
    else
      render 'new'
    end
  end

  def edit
    @campus_rep = CampusRep.find(params[:id])
  end

  def update
    @campus_rep = CampusRep.find(params[:id])
    
    if @campus_rep.update_attributes(params[:campus_rep])
      flash[:success] = "Campus Rep updated."
      redirect_to campus_reps_admin_index_path
    else
      render "edit"
    end
  end
end

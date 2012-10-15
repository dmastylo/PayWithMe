class PaymentsController < ApplicationController

  # Before Filters
  before_filter :authenticate_user!

  def new
    @payment = current_user.expected_payments.new
    @processors = Processor.all
  end

  def create
    @payment = current_user.expected_payments.new(params[:payment].except(:unfinished))

    if !params[:payment][:unfinished] && @payment.save
      
    else
      @processors = Processor.all
      render "new"
    end
  end

  def edit
  end

  def delete
  end

  def pay
  end

end
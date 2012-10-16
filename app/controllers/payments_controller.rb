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
      @payment.payer.notifications.create(category: "payment", body: "#{current_user.name} has requested money from you.", foreign_id: @payment.id, read: 0)
      redirect_to payments_path
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

  def index
  end

end
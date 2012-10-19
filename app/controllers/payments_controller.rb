class PaymentsController < ApplicationController

  # Before Filters
  before_filter :authenticate_user!
  before_filter :correct_user_to_pay, only: :pay
  before_filter :correct_user_to_edit, only: [:edit, :delete, :update]
  before_filter :valid_processor, only: :pay

  def new
    @payment = current_user.expected_payments.new
    @processors = Processor.all
  end

  def create
    @payment = current_user.expected_payments.new(params[:payment].except(:unfinished))
    @processors = Processor.all
    
    if params[:processor]
      @processors.each do |processor|
        if params[:processor][processor.name.downcase]
          @payment.processors << processor
        end
      end
    end

    if !params[:payment][:unfinished] && @payment.save
      @payment.payer.notifications.create(category: "payment", body: "#{current_user.name} has requested money from you.", foreign_id: @payment.id, read: 0)
      redirect_to payments_path
    else
      render "new"
    end
  end

  def edit
    @processors = Processor.all
  end

  def update
    @payment.processors.delete_all
    @processors = Processor.all
    
    if params[:processor]
      @processors.each do |processor|
        if params[:processor][processor.name.downcase] == "true"
          @payment.processors << processor
        end
      end
    end

    if @payment.save
      @payment.payer.notifications.create(category: "payment", body: "#{current_user.name} has updated their request for money from you.", foreign_id: @payment.id, read: 0)
      redirect_to payments_path
    else
      render "new"
    end
  end

  def delete
    @payment.destroy
    redirect_to payments_url
  end

  def pay
    if @processor.name == "Dwolla"
      
    end

    # Initiate payment
  end

  def paid
  end

  def index
  end

private

  def correct_user_to_pay
    @payment = current_user.owed_payments.find_by_id(params[:id])
    redirect_to root_url if @payment.nil?
  end

  def correct_user_to_edit
    @payment = current_user.expected_payments.find_by_id(params[:id])
    redirect_to root_url if @payment.nil?
  end

  def valid_processor
    @processor = Processor.find_by_id(params[:processor])
    redirect_to payments_path if !@payment.processors.include?(@processor)
  end

end
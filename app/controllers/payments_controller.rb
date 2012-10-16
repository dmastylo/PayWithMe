class PaymentsController < ApplicationController

  # Before Filters
  before_filter :authenticate_user!
  before_filter :correct_user_to_pay, only: :pay
  before_filter :correct_user_to_edit, only: [:edit, :delete, :update]

  def new
    @payment = current_user.expected_payments.new
    @processors = Processor.all
  end

  def create
    @processors = Processor.all
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
      @payment.payer.notifications.create(category: "payment", body: "#{current_user.name} has requested money from you.", foreign_id: @payment.id, read: 0)
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
    @processor = Processor.find_by_id(params[:processor])

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

end
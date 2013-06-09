class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :user_is_admin

  def index
    @users_count = User.count
    @recent_users = User.where(stub: false).order('created_at DESC').limit(10)

    @events_count = Event.count
    @active_events_count = Event.active_events.count
    @recent_events = Event.find(:all, order: 'created_at DESC', limit: 10)

    @groups_count = Group.count
    @recent_groups = Group.find(:all, order: 'created_at DESC', limit: 10)

    @organizations_count = Organization.count
    @recent_organizations = Organization.find(:all, order: 'created_at DESC', limit: 10)

    @payments_count = Payment.count
    @recent_payments = Payment.where('paid_at IS NOT NULL').order('created_at DESC').limit(10)

    @nudges_count = Nudge.count
    @recent_nudges = Nudge.find(:all, order: 'created_at DESC', limit: 10)

    @campus_reps_count = CampusRep.count
    @recent_campus_reps = CampusRep.find(:all, order: 'created_at DESC', limit: 10)
  end

  def users
    @users = User.paginate(page: params[:page], order: 'created_at DESC')
    @online_users = User.online
    @all_active_last_30_days = User.all_active_last_30_days
    @all_active_last_24_hours = User.all_active_last_24_hours
  end

  def events
    @events = Event.paginate(page: params[:page], order: 'created_at DESC', include: [:payment_methods, :organizer])
    @active_events = Event.active_events
  end

  def groups
    @groups = Group.paginate(page: params[:page], order: 'created_at DESC', include: [:group_users, :organizer])
  end

  def organizations
    @organizations = Organization.order('created_at DESC').paginate(page: params[:page], per_page: 20)
  end

  def payments
    @payments = Payment.where('paid_at IS NOT NULL').paginate(page: params[:page], order: 'created_at DESC', include: [:payer, :payee, :event])
  end

  def nudges
    @nudges = Nudge.paginate(page: params[:page], order: 'created_at DESC')
  end

  def campus_reps
    @campus_reps = CampusRep.paginate(page: params[:page], order: 'created_at DESC')
  end
end

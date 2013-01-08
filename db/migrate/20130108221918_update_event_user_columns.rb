class UpdateEventUserColumns < ActiveRecord::Migration
  def change
  	change_column :event_users, :paid_date, :datetime
  	change_column :event_users, :due_date, :datetime
  	rename_column :event_users, :paid_date, :paid_at
  	rename_column :event_users, :due_date, :due_at
  	add_column :payments, :event_user_id, :integer
  end
end

class AddVisitedEventToEventUsers < ActiveRecord::Migration
  def change
    add_column :event_users, :visited_event, :boolean, default: false
  end
end

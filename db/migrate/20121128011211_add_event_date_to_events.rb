class AddEventDateToEvents < ActiveRecord::Migration
  def change
    add_column :events, :start_at, :datetime
  end
end

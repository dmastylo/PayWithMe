class ChangeDueAtToDateTimeInEvents < ActiveRecord::Migration
  def change
    change_column :events, :due_at, :datetime
  end
end

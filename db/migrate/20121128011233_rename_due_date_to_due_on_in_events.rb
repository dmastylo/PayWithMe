class RenameDueDateToDueOnInEvents < ActiveRecord::Migration
  def up
    rename_column :events, :due_date, :due_on
  end

  def down
  end
end

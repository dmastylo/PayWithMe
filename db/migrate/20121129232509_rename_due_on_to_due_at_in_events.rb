class RenameDueOnToDueAtInEvents < ActiveRecord::Migration
  def up
    rename_column :events, :due_on, :due_at
  end

  def down
  end
end

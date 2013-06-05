class RenameEventCurrencyColumnsAgain < ActiveRecord::Migration
  def change
    rename_column :events, :split_cents, :per_person_cents
    rename_column :events, :goal_cents, :donation_goal_cents
    rename_column :events, :division_type, :collection_type
  end
end

class RenameEventCurrencyColumns < ActiveRecord::Migration
  def change
    rename_column :events, :total_amount_cents, :total_cents
    rename_column :events, :split_amount_cents, :split_cents
    rename_column :events, :fundraiser_goal_cents, :goal_cents
  end
end

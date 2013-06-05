class AddFundraiserGoalToEvent < ActiveRecord::Migration
  def change
    add_column :events, :goal_cents, :integer
  end
end

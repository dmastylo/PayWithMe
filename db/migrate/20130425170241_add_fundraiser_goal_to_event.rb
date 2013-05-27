class AddFundraiserGoalToEvent < ActiveRecord::Migration
  def change
    add_column :events, :fundraiser_goal_cents, :integer
  end
end

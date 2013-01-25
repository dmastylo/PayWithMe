class GetRidOfStartAtInEvent < ActiveRecord::Migration
  def change
    remove_column :events, :start_at
  end
end
